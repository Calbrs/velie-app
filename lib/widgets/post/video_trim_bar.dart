import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';

/// WhatsApp-style video trim bar with real extracted video frames.
///
/// Displays actual thumbnails from the video file side-by-side as the
/// background. Two gold handles set the trim window. A white playhead
/// moves in real-time.
class VideoTrimBar extends StatefulWidget {
  const VideoTrimBar({
    super.key,
    required this.duration,
    required this.startFraction,
    required this.endFraction,
    required this.onChanged,
    required this.barWidth,
    this.videoFilePath,
    this.onFramesLoaded,
    this.onDragStart,
    this.onDragEnd,
    this.positionFraction = 0,
  });

  final Duration duration;
  final double startFraction;
  final double endFraction;
  final void Function(double start, double end) onChanged;

  /// Pixel width of the trim timeline — drives how many thumbnails to extract
  /// (adaptive: ~1 thumbnail per 45px). Must be nonzero once extraction starts.
  final double barWidth;

  /// Absolute path to the video file for thumbnail extraction.
  /// When null, a fallback film-strip pattern is shown.
  final String? videoFilePath;

  /// Called when frame thumbnails have finished extracting.
  final VoidCallback? onFramesLoaded;

  /// Called when the user starts dragging a trim handle.
  final VoidCallback? onDragStart;

  /// Called when the user releases a trim handle.
  final VoidCallback? onDragEnd;

  /// Current playback position (0–1) for the white playhead.
  final double positionFraction;

  @override
  State<VideoTrimBar> createState() => _VideoTrimBarState();
}

class _VideoTrimBarState extends State<VideoTrimBar> {
  static const double _handleW = 22.0;
  static const double _barH    = 60.0;
  static const Color  _gold    = Color(0xFFC99A43);
  static const Color  _dimColor= Color(0xBB000000);

  late double _start;
  late double _end;

  String? _draggingHandle;
  List<Uint8List?> _frames = [];
  bool _loadingFrames = false;
  String? _loadedForPath;
  int _requestId = 0;

  Timer? _hideTimer;
  bool _showHousing = true;

  @override
  void initState() {
    super.initState();
    _start = widget.startFraction;
    _end   = widget.endFraction;
    _loadFrames();
    _resetHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    if (!_showHousing && mounted) {
      setState(() => _showHousing = true);
    }
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showHousing = false);
    });
  }

  @override
  void didUpdateWidget(VideoTrimBar old) {
    super.didUpdateWidget(old);
    if (old.startFraction != widget.startFraction) _start = widget.startFraction;
    if (old.endFraction   != widget.endFraction)   _end   = widget.endFraction;
    _loadFrames();
  }

  Future<void> _loadFrames() async {
    final path = widget.videoFilePath;
    if (path == null || path == _loadedForPath || _loadingFrames) return;
    if (widget.duration == Duration.zero) return;

    _loadingFrames = true;
    _loadedForPath = path;

    final totalMs = widget.duration.inMilliseconds;
    // One thumbnail per ~45px of timeline, tuned for the real widget width.
    final count = (widget.barWidth / 45).ceil().clamp(8, 24);

    final id = ++_requestId;
    
    // Initialize the strip with nulls to show the placeholder background
    final List<Uint8List?> frames = List.filled(count, null);
    if (mounted) setState(() => _frames = List.from(frames));

    final timestamps = List<int>.generate(
      count,
      (i) => (totalMs * i / (count - 1)).round(),
    );
    try {
      // Native batch call: opens the video exactly ONCE and extracts all frames
      // sequentially within the native layer using OPTION_CLOSEST_SYNC.
      // This takes ~200ms total and avoids crashing the Android hardware decoder
      // (which happens if we spawn multiple concurrent MediaMetadataRetrievers).
      final List<Uint8List?> batchBytes = await VideoThumbnail.thumbnailDataBatch(
        video: path,
        timeMs: timestamps,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 160,
        maxHeight: 90,
        quality: 60,
      );
      
      if (mounted && id == _requestId) {
        setState(() => _frames = List.from(batchBytes));
        widget.onFramesLoaded?.call();
      }
    } catch (e) {
      debugPrint('TrimStrip batch extract error: $e');
      if (mounted && id == _requestId) {
        setState(() => _frames = List.filled(count, null));
      }
    }
    
    _loadingFrames = false;
    if (mounted && widget.videoFilePath != _loadedForPath) {
      _loadFrames();
    }
  }

  String _fmt(double fraction) {
    final ms = (widget.duration.inMilliseconds * fraction).round();
    final d  = Duration(milliseconds: ms);
    final m  = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s  = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _resetHideTimer(),
      onPanDown: (_) => _resetHideTimer(),
      child: LayoutBuilder(builder: (ctx, constraints) {
      final totalW = constraints.maxWidth;
      final innerW = totalW - _handleW * 2;

      final startPx   = _handleW + _start * innerW;
      final endPx     = _handleW + _end   * innerW;

      final clampedPos = widget.positionFraction.clamp(_start, _end);
      final playheadPx = _handleW + clampedPos * innerW;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Floating Preview Bubble Area & Static Time Labels
          SizedBox(
            width: totalW,
            height: 24, // Reduced from 65 to close the gap
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Static time labels when NOT dragging
                if (_draggingHandle == null)
                  Positioned(
                    bottom: 2,
                    // Fixed position — stays put at the start handle while the
                    // value counts up with playback (a progress readout, not a
                    // moving indicator).
                    left: (startPx - _handleW).clamp(0.0, totalW - 40.0),
                    child: Text(_fmt(clampedPos), style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                if (_draggingHandle == null)
                  Positioned(
                    bottom: 2,
                    right: (totalW - endPx - _handleW * 2).clamp(0.0, totalW - 40.0),
                    child: Text(_fmt(_end), style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),

                // Floating bubble when DRAGGING (allowed to overflow upward)
                if (_draggingHandle != null)
                  Positioned(
                    bottom: 2,
                    // Center the bubble (width 54) over the handle
                    left: (_draggingHandle == 'start' 
                            ? (startPx - _handleW + 11 - 27) 
                            : (endPx + 11 - 27))
                          .clamp(0.0, totalW - 54.0),
                    child: _buildPreviewBubble(_draggingHandle == 'start' ? _start : _end),
                  ),
              ],
            ),
          ),

          // Trim strip
          SizedBox(
            width: totalW,
            height: _barH,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // ── Video frame thumbnails (or fallback) ──────────────
                Positioned(
                  top: 6,
                  bottom: 6,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: _frames.isNotEmpty
                        ? _FrameStrip(frames: _frames, width: totalW, height: _barH - 12)
                        : _FallbackStrip(width: totalW, height: _barH - 12),
                  ),
                ),

                // ── Dim: left of start handle ─────────────────────────
                if (_start > 0.001)
                  Positioned(
                    left: 0, top: 6, bottom: 6, width: startPx,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomLeft: Radius.circular(4),
                      ),
                      child: Container(color: _dimColor),
                    ),
                  ),

                // ── Dim: right of end handle ──────────────────────────
                if (_end < 0.999)
                  Positioned(
                    left: endPx + _handleW, top: 6, bottom: 6, right: 0,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                      child: Container(color: _dimColor),
                    ),
                  ),

                // ── White playhead ────────────────────────────────────
                Positioned(
                  left: playheadPx - 1.5,
                  top: 4, bottom: 4,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 4)],
                    ),
                  ),
                ),


                // ── LEFT handle ───────────────────────────────────────
                if (_showHousing || _draggingHandle != null)
                  Positioned(
                    left: startPx - _handleW,
                    top: 0, bottom: 0, width: _handleW,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragStart: (_) {
                        setState(() => _draggingHandle = 'start');
                        widget.onDragStart?.call();
                      },
                      onHorizontalDragEnd: (_) {
                        setState(() => _draggingHandle = null);
                        widget.onDragEnd?.call();
                      },
                      onHorizontalDragCancel: () {
                        setState(() => _draggingHandle = null);
                        widget.onDragEnd?.call();
                      },
                      onHorizontalDragUpdate: (d) {
                        _resetHideTimer();
                        final ns = (_start + d.delta.dx / innerW).clamp(0.0, _end - 0.04);
                        setState(() => _start = ns);
                        widget.onChanged(_start, _end);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _gold,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: _buildGripLines(),
                        ),
                      ),
                    ),
                  ),

                // ── RIGHT handle ──────────────────────────────────────
                if (_showHousing || _draggingHandle != null)
                  Positioned(
                    left: endPx,
                    top: 0, bottom: 0, width: _handleW,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragStart: (_) {
                        setState(() => _draggingHandle = 'end');
                        widget.onDragStart?.call();
                      },
                      onHorizontalDragEnd: (_) {
                        setState(() => _draggingHandle = null);
                        widget.onDragEnd?.call();
                      },
                      onHorizontalDragCancel: () {
                        setState(() => _draggingHandle = null);
                        widget.onDragEnd?.call();
                      },
                      onHorizontalDragUpdate: (d) {
                        _resetHideTimer();
                        final ne = (_end + d.delta.dx / innerW).clamp(_start + 0.04, 1.0);
                        setState(() => _end = ne);
                        widget.onChanged(_start, _end);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _gold,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: _buildGripLines(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    }),
    );
  }

  Widget _buildPreviewBubble(double fraction) {
    Uint8List? thumb;
    if (_frames.isNotEmpty) {
      final index = (fraction * (_frames.length - 1)).round().clamp(0, _frames.length - 1);
      thumb = _frames[index];
    }
    
    return Container(
      width: 54,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              child: thumb != null 
                  ? Image.memory(thumb, fit: BoxFit.cover, gaplessPlayback: true)
                  : Container(color: const Color(0xFF2C2926)),
            ),
          ),
          Container(
            height: 18,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
            ),
            child: Text(
              _fmt(fraction), 
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGripLines() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _gripLine(10), // left (outer)
        const SizedBox(width: 2.5),
        _gripLine(16), // middle (taller)
        const SizedBox(width: 2.5),
        _gripLine(10), // right (outer)
      ],
    );
  }

  Widget _gripLine(double height) {
    return Container(
      width: 1.5,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}

/// Displays extracted video frame thumbnails side by side.
class _FrameStrip extends StatelessWidget {
  const _FrameStrip({required this.frames, required this.width, required this.height});
  final List<Uint8List?> frames;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: frames.map((bytes) {
        return Expanded(
          child: bytes != null
              ? Image.memory(
                  bytes,
                  fit: BoxFit.cover,
                  height: height,
                  gaplessPlayback: true,
                )
              : Container(color: const Color(0xFF2C2926)),
        );
      }).toList(),
    );
  }
}

/// Fallback shown while frames are loading — a simple dark strip with a
/// loading indicator.
class _FallbackStrip extends StatelessWidget {
  const _FallbackStrip({required this.width, required this.height});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFF2C2926),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFC99A43),
          ),
        ),
      ),
    );
  }
}
