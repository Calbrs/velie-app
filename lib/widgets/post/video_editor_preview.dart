import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

class VideoEditorPreview extends StatefulWidget {
  final Uint8List videoBytes;
  final String? musicFilePath;
  final Duration? audioStartOffset;
  final String? watermarkImagePath;

  /// Restored preview position of the watermark (used when the watermark image
  /// source changes — the preview keeps its own live state while dragging).
  final Offset watermarkPosition;

  /// Restored preview scale of the watermark (1.0 = 100px box).
  final double watermarkScale;

  /// Called continuously while the user drags/scales the watermark with the
  /// latest live [Offset] and scale — use this to persist, without rebuilding.
  final void Function(Offset position, double scale)? onWatermarkChanged;

  /// Called once when a watermark drag or resize gesture begins — use this to
  /// record an undo/redo history point (capturing the pre-drag state).
  final VoidCallback? onWatermarkDragStart;

  /// Bumped by the parent to force this preview to re-adopt the authoritative
  /// [watermarkPosition]/[watermarkScale] (e.g. after an undo/redo).
  final int watermarkResetTick;

  /// If true, the video will automatically play (unless paused by the user).
  /// If false, it stays paused (e.g. waiting for thumbnails to load).
  final bool shouldPlay;

  /// True when the user is actively dragging a trim handle.
  final bool isDraggingTrim;

  /// Called once after the player initialises with the video's total duration.
  final void Function(Duration duration)? onDurationLoaded;

  /// Called with the absolute path of the temp video file once it is written
  /// to disk — the trim bar uses this path to extract frame thumbnails.
  final void Function(String path)? onFileReady;

  /// Fraction (0–1) of the video to start playback from.
  final double trimStart;

  /// Fraction (0–1) of the video to stop playback at (loops back to trimStart).
  final double trimEnd;

  /// Called every frame with the current playback position as a fraction (0–1).
  /// Use a ValueNotifier on the parent side — don't call setState here.
  final void Function(double fraction)? onPositionChanged;

  /// Notifies the parent of the current play state.
  final ValueNotifier<bool>? isPlayingNotifier;

  /// Volume of the original video track (0.0 to 1.0).
  final double originalVolume;

  /// Volume of the background music (0.0 to 1.0).
  final double musicVolume;

  const VideoEditorPreview({
    super.key,
    required this.videoBytes,
    this.musicFilePath,
    this.audioStartOffset,
    this.watermarkImagePath,
    this.watermarkPosition = const Offset(20, 20),
    this.watermarkScale = 1.0,
    this.onWatermarkChanged,
    this.onWatermarkDragStart,
    this.watermarkResetTick = 0,
    this.shouldPlay = true,
    this.isDraggingTrim = false,
    this.originalVolume = 1.0,
    this.musicVolume = 1.0,
    this.isPlayingNotifier,
    this.onDurationLoaded,
    this.onFileReady,
    this.trimStart = 0.0,
    this.trimEnd = 1.0,
    this.onPositionChanged,
  });

  @override
  State<VideoEditorPreview> createState() => VideoEditorPreviewState();
}

class VideoEditorPreviewState extends State<VideoEditorPreview> {
  VideoPlayerController? _controller;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration? _audioDuration;

  File? _tempVideoFile;
  bool _isInitialized = false;
  // True when the user explicitly tapped pause — trim-loop must not override.
  bool _userPaused = false;
  // Prevents overlapping seekTo calls which freeze the Android VideoPlayer
  bool _isSeeking = false;
  // If a seek arrives while one is in flight, remember the newest target and
  // run it once the current seek finishes — so the last drag position always
  // wins instead of being silently dropped (which would leave the video paused).
  bool get _shouldAutoPlay =>
      widget.shouldPlay && !_userPaused && !widget.isDraggingTrim;

  Duration? _pendingSeek;
  // Tracks the last rendered play state so _onFrame can rebuild the icon the
  // moment the controller's playing state actually changes.
  bool _lastPlaying = false;

  Offset _watermarkPosition = const Offset(20, 20);
  double _watermarkScale = 1.0;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void didUpdateWidget(VideoEditorPreview oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.videoBytes != widget.videoBytes) {
      _initPlayer();
      return;
    }

    // Restore watermark position/size when a new logo is picked, without
    // touching the live drag state.
    if (oldWidget.watermarkImagePath != widget.watermarkImagePath) {
      _watermarkPosition = widget.watermarkPosition;
      _watermarkScale = widget.watermarkScale;
    }
    // Forced re-adoption (e.g. after an undo/redo of a move/resize).
    if (oldWidget.watermarkResetTick != widget.watermarkResetTick) {
      _watermarkPosition = widget.watermarkPosition;
      _watermarkScale = widget.watermarkScale;
    }

    // Music source or offset changed
    if (oldWidget.musicFilePath != widget.musicFilePath ||
        oldWidget.audioStartOffset != widget.audioStartOffset) {
      if (widget.musicFilePath != null) {
        _setupMusic(widget.musicFilePath!);
      } else {
        _audioPlayer.stop();
      }

      // Force restart video from trimStart to sync audio
      final ctrl = _controller;
      if (ctrl != null && ctrl.value.duration.inMilliseconds > 0) {
        final startDur = Duration(
          milliseconds: (widget.trimStart * ctrl.value.duration.inMilliseconds)
              .round(),
        );
        _seekTo(startDur);
      }
    }

    if (oldWidget.originalVolume != widget.originalVolume) {
      _controller?.setVolume(widget.originalVolume);
    }
    if (oldWidget.musicVolume != widget.musicVolume) {
      _audioPlayer.setVolume(widget.musicVolume);
    }

    // shouldPlay toggled (frames loaded)
    if (!oldWidget.shouldPlay && widget.shouldPlay) {
      if (_shouldAutoPlay) _startPlayback();
    }

    // Handle drag state changes
    final dur = _controller?.value.duration;
    if (dur != null && dur > Duration.zero) {
      final startDur = Duration(
        milliseconds: (widget.trimStart * dur.inMilliseconds).round(),
      );
      final endDur = Duration(
        milliseconds: (widget.trimEnd * dur.inMilliseconds).round(),
      );

      if (!oldWidget.isDraggingTrim && widget.isDraggingTrim) {
        // Drag started
        _controller?.pause();
      } else if (oldWidget.isDraggingTrim && !widget.isDraggingTrim) {
        // Drag ended. Matching the intent of a "trim-then-play" UX, ending a
        // drag always attempts to resume playback — so clear the explicit-pause
        // flag before seeking (otherwise _seekTo won't play).
        _userPaused = false;
        _seekTo(startDur);
      } else if (widget.isDraggingTrim) {
        // While dragging, preview the exact frame of the handle being dragged.
        if (oldWidget.trimStart != widget.trimStart) {
          _seekTo(startDur);
        } else if (oldWidget.trimEnd != widget.trimEnd) {
          _seekTo(endDur);
        }
      }
    }
  }

  /// Seeks to [target] without overlapping seeks (overlapping seeks freeze
  /// Android's VideoPlayer). `_isSeeking` is ALWAYS reset, even on error, and
  /// the previous play state is always restored, so a seek can never leave the
  /// video wedged in "paused"/"playing".
  Future<void> _seekTo(Duration target) async {
    final ctrl = _controller;
    if (ctrl == null) return;

    // A seek is already in flight — remember the newest target and re-run it
    // when the current one finishes (the last drag position always wins).
    if (_isSeeking) {
      _pendingSeek = target;
      return;
    }

    // Restore the pre-seek play state based on INTENT (shouldPlay and whether
    // the user explicitly paused), never on ctrl.value.isPlaying — that flag
    // lags behind on Android after a pause()/seekTo() burst, and trusting it
    // is exactly what left the video wedged paused.
    _isSeeking = true;
    // Watchdog: if a platform future never completes (e.g. the controller was
    // disposed mid-await), force the guard open so the player can never wedge
    // in "_isSeeking == true" and queue seeks forever.
    final watchdog = Timer(const Duration(milliseconds: 2500), () {
      if (_isSeeking) {
        debugPrint('VideoEditorPreview seek watchdog fired');
        _isSeeking = false;
      }
    });
    try {
      // Pause before seek to prevent the Android freeze.
      await ctrl.pause();
      await ctrl.seekTo(target);

      // Sync audio
      if (widget.musicFilePath != null) {
        final startMs = (widget.trimStart * ctrl.value.duration.inMilliseconds)
            .round();
        final baseOffset = widget.audioStartOffset ?? Duration.zero;
        final targetAudioPosMs =
            baseOffset.inMilliseconds +
            (target.inMilliseconds - startMs).clamp(0, 99999999);

        if (_audioDuration != null &&
            targetAudioPosMs >= _audioDuration!.inMilliseconds) {
          // Audio doesn't reach this far, just stop it to prevent ExoPlayer from failing
          await _audioPlayer.stop();
        } else {
          try {
            await _audioPlayer.seek(Duration(milliseconds: targetAudioPosMs));
          } catch (e) {
            debugPrint('Audio seek error: $e');
          }
        }
      }

      await Future<void>.delayed(const Duration(milliseconds: 30));
      // Check intent at play-time, not seek-start, so a concurrent tap-to-pause
      // during the seek is respected.
      if (_shouldAutoPlay && mounted) {
        await _startPlayback();
      }
    } catch (e) {
      debugPrint('VideoEditorPreview seek error: $e');
    } finally {
      watchdog.cancel();
      // Process the newest seek target (from a rapid drag) before the frame
      // callbacks resume, so playback always lands on the final trimStart.
      final pending = _pendingSeek;
      _pendingSeek = null;
      // Reset the guard FIRST, then fire the follow-up seek, so `_isSeeking`
      // can never remain true even if the follow-up is interrupted/disposed.
      _isSeeking = false;
      if (pending != null && mounted) {
        unawaited(_seekTo(pending));
      }
    }
  }

  /// Starts playback, re-issuing play() up to 4 times across ~320ms.
  /// Android's ExoPlayer silently drops (or rejects) a play() issued after the
  /// player sat paused for a while; re-issuing forces it to honor the resume.
  /// Each attempt is guarded individually so one thrown play() can never kill
  /// the whole retry sequence (which otherwise leaves the video permanently
  /// paused). Retries are NOT gated on ctrl.value.isPlaying — that flag lags
  /// and cannot decide here. Replaying on an already-playing controller is a
  /// no-op.
  Future<void> _startPlayback() async {
    final ctrl = _controller;
    if (ctrl == null) return;
    for (var i = 0; i < 4; i++) {
      if (!mounted || !_shouldAutoPlay) return;
      try {
        await ctrl.play();
      } catch (e) {
        debugPrint('VideoEditorPreview play error: $e');
      }
      await Future<void>.delayed(const Duration(milliseconds: 80));
    }
  }

  /// Resumes after a user tap. The single source of truth is [widget.shouldPlay]
  /// + [_userPaused], NOT ctrl.value.isPlaying (which lags on Android).
  ///
  /// Only routes through [_seekTo] (pause→seek→play) when the playhead has
  /// drifted OUTSIDE the trim window and needs pulling back to trimStart — e.g.
  /// right after a trim drag. For ordinary resume inside the window, play
  /// directly: the unconditional retries in [_startPlayback] already handle
  /// Android's dropped-play-after-pause quirk, so a redundant pause→seek on the
  /// same position only risks a stale/frozen frame.
  Future<void> _resumePlayback() async {
    final ctrl = _controller;
    if (ctrl == null) return;

    final dur = ctrl.value.duration;
    if (dur.inMilliseconds > 0) {
      final pos = ctrl.value.position;
      final startMs = (widget.trimStart * dur.inMilliseconds).round();
      final endMs = (widget.trimEnd * dur.inMilliseconds).round();
      if (pos.inMilliseconds < startMs || pos.inMilliseconds >= endMs) {
        await _seekTo(Duration(milliseconds: startMs));
        return;
      }
    }
    await _startPlayback();
  }

  Future<void> _setupMusic(String path) async {
    try {
      // Critical: audioplayers' default audio context uses
      // AndroidAudioFocus.gain — it requests exclusive audio focus. When the
      // video (ExoPlayer) also grabs focus, audioplayers receives
      // onAudioFocusChange(-1) (AUDIOFOCUS_LOSS) and its ModernFocusManager
      // auto-pauses the music, so the two tracks fight and never play together.
      // Setting audioFocus: none stops audioplayers from requesting focus and
      // from pausing on focus loss — ExoPlayer keeps focus and both play.
      await _audioPlayer.setAudioContext(
        AudioContext(
          android: AudioContextAndroid(audioFocus: AndroidAudioFocus.none),
        ),
      );
      await _audioPlayer.setSourceDeviceFile(path);
      // Wait for duration to be ready
      final dur = await _audioPlayer.getDuration();
      _audioDuration = dur;
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      // It won't loop automatically, we'll sync it on video loop.
      final offset = widget.audioStartOffset ?? Duration.zero;
      await _audioPlayer.seek(offset);
    } catch (e) {
      debugPrint('Music load error: $e');
    }
  }

  Future<void> _initPlayer() async {
    try {
      _controller?.removeListener(_onFrame);
      _controller?.dispose();
      _userPaused = false;
      if (mounted) setState(() => _isInitialized = false);

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/velie_prev_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );
      await tempFile.writeAsBytes(widget.videoBytes);
      _tempVideoFile = tempFile;
      // Notify parent immediately so the trim bar can start loading frames.
      widget.onFileReady?.call(tempFile.path);

      _controller = VideoPlayerController.file(tempFile);
      await _controller!.initialize();

      // Manual looping so we can enforce the trim window.
      _controller!.setLooping(false);
      _controller!.addListener(_onFrame);

      if (widget.musicFilePath != null) {
        await _setupMusic(widget.musicFilePath!);
      }
      _controller!.setVolume(widget.originalVolume);
      _audioPlayer.setVolume(widget.musicVolume);

      // Start from trim start
      final dur = _controller!.value.duration;
      final startDur = Duration(
        milliseconds: (widget.trimStart * dur.inMilliseconds).round(),
      );
      if (startDur > Duration.zero) await _controller!.seekTo(startDur);

      if (widget.shouldPlay && !_userPaused) await _controller!.play();
      widget.onDurationLoaded?.call(dur);
      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint('VideoEditorPreview init error: $e');
    }
  }

  void _onFrame() {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;

    // Rebuild when the platform play state actually flips so the play/pause
    // icon always reflects reality (the timer/notifier path doesn't rebuild).
    final playing = ctrl.value.isPlaying;
    if (playing != _lastPlaying) {
      _lastPlaying = playing;
      if (mounted) setState(() {});
      widget.isPlayingNotifier?.value = playing;
    }

    final dur = ctrl.value.duration;
    if (dur.inMilliseconds == 0) return;

    final posMs = ctrl.value.position.inMilliseconds;
    final endMs = (widget.trimEnd * dur.inMilliseconds).round();
    final startMs = (widget.trimStart * dur.inMilliseconds).round();

    // Report position to trim bar — no setState, just ValueNotifier.value
    widget.onPositionChanged?.call(posMs / dur.inMilliseconds);

    if (_isSeeking) return;

    // Loop within trim window ONLY if user hasn't manually paused AND not currently dragging.
    if (!widget.isDraggingTrim && !_userPaused) {
      // If we passed the end OR somehow fell significantly before the start
      if (posMs >= endMs || posMs < (startMs - 500)) {
        _seekTo(Duration(milliseconds: startMs));
      }
    }

    // Audio sync
    if (!ctrl.value.isPlaying) {
      if (_audioPlayer.state == PlayerState.playing) _audioPlayer.pause();
    } else {
      if (_audioPlayer.state != PlayerState.playing &&
          widget.musicFilePath != null) {
        if (_audioPlayer.state == PlayerState.paused) {
          _audioPlayer.resume();
        } else {
          final startMs = (widget.trimStart * dur.inMilliseconds).round();
          final diff = posMs > startMs ? posMs - startMs : 0;
          final targetAudioPosMs =
              (widget.audioStartOffset?.inMilliseconds ?? 0) + diff;

          if (_audioDuration == null ||
              targetAudioPosMs < _audioDuration!.inMilliseconds) {
            try {
              _audioPlayer.play(
                DeviceFileSource(widget.musicFilePath!),
                position: Duration(milliseconds: targetAudioPosMs),
              );
            } catch (e) {
              debugPrint('Audio play error: $e');
            }
          }
        }
      }
    }
  }

  /// Forces the preview to pause regardless of the user/auto-play state. Used
  /// by the parent while an inline render is in progress (and before handing off
  /// to the schedule screen) so the loop, audio and frame updates can't keep
  /// playing in the background. Sets [_userPaused] so the trim-loop in [_onFrame]
  /// won't restart playback while paused.
  Future<void> pausePlayback() async {
    _userPaused = true;
    _pendingSeek = null;
    try {
      await _controller?.pause();
      // Explicitly silence the background music too — pausing the video alone
      // relies on `_onFrame` firing to stop audioplayers, which isn't guaranteed,
      // so otherwise the song keeps playing on the schedule screen underneath.
      if (_audioPlayer.state == PlayerState.playing ||
          _audioPlayer.state == PlayerState.paused) {
        await _audioPlayer.pause();
      }
    } catch (_) {}
    if (mounted) {
      _lastPlaying = false;
      setState(() {});
    }
    widget.isPlayingNotifier?.value = false;
  }

  /// Toggles the play/pause state.
  void togglePlayPause() {
    final ctrl = _controller;
    if (ctrl == null) return;

    // If the user explicitly paused, OR the video naturally stopped/stalled,
    // the intent of a tap is to PLAY.
    if (_userPaused || !ctrl.value.isPlaying) {
      _userPaused = false;
      // Drop any stale queued seek so an old drag target can't win over the
      // user's explicit play tap. An in-flight seek's play-time intent check
      // will honor _userPaused=false on its own.
      _pendingSeek = null;
      setState(() {});
      _resumePlayback();
    } else {
      _userPaused = true;
      ctrl.pause();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onFrame);
    _controller?.dispose();
    _audioPlayer.dispose();
    if (_tempVideoFile?.existsSync() == true) _tempVideoFile!.deleteSync();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),

          // Draggable + resizable watermark
          if (widget.watermarkImagePath != null)
            Positioned(
              left: _watermarkPosition.dx,
              top: _watermarkPosition.dy,
              child: GestureDetector(
                onPanStart: (_) => widget.onWatermarkDragStart?.call(),
                onPanUpdate: (d) {
                  setState(() => _watermarkPosition += d.delta);
                  widget.onWatermarkChanged?.call(
                    _watermarkPosition,
                    _watermarkScale,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white54, width: 1),
                    color: Colors.black26,
                  ),
                  child: Stack(
                    children: [
                      Image.file(
                        File(widget.watermarkImagePath!),
                        width: 100 * _watermarkScale,
                        height: 100 * _watermarkScale,
                        fit: BoxFit.contain,
                      ),
                      // Resize handle — drag the bottom-right corner to scale.
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onPanStart: (_) =>
                              widget.onWatermarkDragStart?.call(),
                          onPanUpdate: (d) {
                            final delta = d.delta.dx;
                            if (delta == 0) return;
                            double next = _watermarkScale + (delta / 100);
                            if (next < 0.3) next = 0.3;
                            if (next > 4.0) next = 4.0;
                            setState(() => _watermarkScale = next);
                            widget.onWatermarkChanged?.call(
                              _watermarkPosition,
                              _watermarkScale,
                            );
                          },
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black54),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Icon(
                              Icons.open_in_full,
                              size: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
