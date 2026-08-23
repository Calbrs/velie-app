import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/video_composition_model.dart';
import '../../../providers/create_post_provider.dart';
import '../../../providers/quick_tags_provider.dart';
import '../../../services/local_video_render_service.dart';
import '../../../widgets/post/device_audio_picker_sheet.dart';
import '../../../widgets/post/save_draft_dialog.dart';
import '../../../widgets/post/video_editor_preview.dart';
import '../../../widgets/post/video_trim_bar.dart';
import '../../../widgets/post/audio_track_slider.dart';
import 'package:audioplayers/audioplayers.dart';

class VideoStatusScreen extends StatefulWidget {
  const VideoStatusScreen({super.key});

  @override
  State<VideoStatusScreen> createState() => _VideoStatusScreenState();
}

class _VideoStatusScreenState extends State<VideoStatusScreen>
    with WidgetsBindingObserver {
  final ImagePicker _picker = ImagePicker();
  late final TextEditingController _captionController;

  String? _musicFilePath;
  String? _musicFileName;
  int? _musicId;
  String? _watermarkImagePath;
  Offset _watermarkPosition = const Offset(20, 20);
  double _watermarkScale = 1.0;
  final List<VideoTextOverlay> _textOverlays = [];

  // Trim state
  Duration _videoDuration = Duration.zero;
  String? _videoFilePath;
  bool _framesLoaded = false;
  bool _isDraggingTrim = false;
  double _trimStart = 0.0;
  double _trimEnd = 1.0;
  double _originalVolume = 1.0;
  double _musicVolume = 1.0;
  Duration _audioDuration = Duration.zero;
  Duration _audioStartOffset = Duration.zero;
  // Position notifier — updated every frame WITHOUT calling setState on the
  // whole screen. Only the VideoTrimBar listens to it.
  final ValueNotifier<double> _positionNotifier = ValueNotifier(0.0);
  final ValueNotifier<bool> _isPlayingNotifier = ValueNotifier(false);
  final GlobalKey<VideoEditorPreviewState> _previewKey = GlobalKey();

  // Undo / redo history — snapshot-based over all editable state.
  static const int _maxHistory = 50;
  final List<_EditorSnapshot> _undoStack = [];
  final List<_EditorSnapshot> _redoStack = [];
  int _watermarkResetTick = 0;

  bool get _canUndo => _undoStack.isNotEmpty;
  bool get _canRedo => _redoStack.isNotEmpty;

  // Inline render state (Endelea) — combines all edits to one output while
  // showing a progress card on THIS screen (no navigation away).
  final LocalVideoRenderService _renderService = LocalVideoRenderService();
  final ValueNotifier<double?> _renderProgress = ValueNotifier(null);
  bool _isRendering = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final draft = context.read<CreatePostProvider>();
    _captionController = TextEditingController(text: draft.caption);
    context.read<QuickTagsProvider>().load();
  }

  /// Pause the video when another route is pushed on top (e.g. SchedulePostScreen).
  /// GoRouter uses the Navigator under the hood, so this fires correctly.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If the route is no longer the top-most, pause playback.
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) {
      _previewKey.currentState?.pausePlayback();
    }
  }

  /// Pause when the app is backgrounded.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _previewKey.currentState?.pausePlayback();
    }
  }

  void _syncEditsToProvider() {
    if (!mounted) return;
    context.read<CreatePostProvider>().setVideoEdits(
      trimStart: _trimStart,
      trimEnd: _trimEnd,
      musicFilePath: _musicFilePath,
      musicFileName: _musicFileName,
      musicId: _musicId,
      audioStartOffsetMs: _audioStartOffset.inMilliseconds,
      audioDurationMs: _audioDuration.inMilliseconds,
      originalVolume: _originalVolume,
      musicVolume: _musicVolume,
      watermarkImagePath: _watermarkImagePath,
      watermarkTransformJson: _watermarkImagePath == null
          ? null
          : jsonEncode({
              'dx': _watermarkPosition.dx,
              'dy': _watermarkPosition.dy,
              'scale': _watermarkScale,
            }),
      textOverlaysJson: jsonEncode(
        _textOverlays.map((e) => e.toJson()).toList(),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // UNDO / REDO
  // ---------------------------------------------------------------------

  _EditorSnapshot _capture() => _EditorSnapshot(
    trimStart: _trimStart,
    trimEnd: _trimEnd,
    musicFilePath: _musicFilePath,
    musicFileName: _musicFileName,
    musicId: _musicId,
    audioStartOffset: _audioStartOffset,
    audioDuration: _audioDuration,
    originalVolume: _originalVolume,
    musicVolume: _musicVolume,
    watermarkImagePath: _watermarkImagePath,
    watermarkPosition: _watermarkPosition,
    watermarkScale: _watermarkScale,
    textOverlays: List.of(_textOverlays),
  );

  void _apply(_EditorSnapshot s) {
    _trimStart = s.trimStart;
    _trimEnd = s.trimEnd;
    _musicFilePath = s.musicFilePath;
    _musicFileName = s.musicFileName;
    _musicId = s.musicId;
    _audioStartOffset = s.audioStartOffset;
    _audioDuration = s.audioDuration;
    _originalVolume = s.originalVolume;
    _musicVolume = s.musicVolume;
    _watermarkImagePath = s.watermarkImagePath;
    _watermarkPosition = s.watermarkPosition;
    _watermarkScale = s.watermarkScale;
    _textOverlays
      ..clear()
      ..addAll(s.textOverlays);
  }

  /// Records the state BEFORE a committed edit. Call at every edit commit.
  void _recordHistory() {
    _undoStack.add(_capture());
    if (_undoStack.length > _maxHistory) _undoStack.removeAt(0);
    _redoStack.clear();
    if (mounted) setState(() {});
  }

  /// Reverts the latest committed edit.
  void _undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(_capture());
    final prev = _undoStack.removeLast();
    _apply(prev);
    _applyStateAfterHistory();
  }

  /// Re-applies a reverted edit.
  void _redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(_capture());
    final next = _redoStack.removeLast();
    _apply(next);
    _applyStateAfterHistory();
  }

  /// Common post-undo/redo: reflect changes (watermark re-adopted by preview),
  /// persist, and refresh buttons.
  void _applyStateAfterHistory() {
    _watermarkResetTick++; // force the preview to adopt the restored position/scale
    setState(() {});
    _syncEditsToProvider();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _captionController.dispose();
    _positionNotifier.dispose();
    _isPlayingNotifier.dispose();
    _renderProgress.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final draft = context.read<CreatePostProvider>();
    if (!draft.hasImage && !draft.isEditing) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Chagua video kwanza')));
      return;
    }
    await _renderVideo();
  }

  /// Combines every edit (trim, music, watermark, text overlays) into a single
  /// rendered `.mp4` INLINE on this screen — showing a progress card with the
  /// percentage instead of navigating to a separate render screen. On success it
  /// clears the persisted draft in the background, then hands the finished
  /// video to the "Ratiba ya Post" screen for posting management.
  Future<void> _renderVideo() async {
    final draft = context.read<CreatePostProvider>();
    final bytes = draft.imageBytes;
    if (bytes == null || _isRendering) return;

    _isRendering = true;
    _renderProgress.value = null;

    // Pause the editor preview so its playlist/audio/loop can't interfere with
    // the FFmpeg render running in the background.
    await _previewKey.currentState?.pausePlayback();

    if (!mounted) return;
    final navigator = Navigator.of(context);
    showRenderProgressDialog(context: context, progress: _renderProgress);

    try {
      final outputBytes = await _renderService.render(
        videoBytes: bytes,
        videoExtension: _videoExtensionOf(draft.imageName),
        musicPath: _musicFilePath,
        audioStartOffset: _audioStartOffset,
        watermarkPath: _watermarkImagePath,
        textOverlays: List.unmodifiable(_textOverlays),
        trimStart: _trimStart,
        trimEnd: _trimEnd,
        resolution: '1080x1920',
        onProgress: (p) => _renderProgress.value = p,
      );

      if (!mounted) return;
      draft.setImage(outputBytes, 'rendered_video.mp4');
      navigator.pop(); // close the progress card

      // Delete the old draft content in the background — the rendered media is
      // now what the scheduler reads.
      unawaited(draft.releaseAutoDraft());

      if (!mounted) return;
      context.go('/post/schedule');
    } catch (e) {
      if (!mounted) return;
      navigator.pop();
      setState(() {
        _isRendering = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Imeshindwa kuchakata video: $e')));
    } finally {
      if (mounted) setState(() => _isRendering = false);
    }
  }

  static String _videoExtensionOf(String? name) {
    if (name == null) return 'mp4';
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return 'mp4';
    final ext = name.substring(dot + 1).toLowerCase();
    return ext.isEmpty ? 'mp4' : ext;
  }

  void _insertText(String text) {
    final currentText = _captionController.text;
    final selection = _captionController.selection;
    if (selection.start >= 0 && selection.end >= 0) {
      final newText = currentText.replaceRange(
        selection.start,
        selection.end,
        text,
      );
      _captionController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + text.length,
        ),
      );
    } else {
      _captionController.text =
          currentText + (currentText.isEmpty ? '' : ' ') + text;
      _captionController.selection = TextSelection.collapsed(
        offset: _captionController.text.length,
      );
    }
    context.read<CreatePostProvider>().setCaption(_captionController.text);
  }

  // ---------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final draft = context.watch<CreatePostProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        confirmComposerBack(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        // Keep the canvas + trim bar fixed while the caption/tag keyboard opens.
        // The modal sheets manage their own keyboard insets, so the underlying
        // layout must NOT re-flow (no resizeToAvoidBottomInset) — otherwise the
        // Expanded canvas gets compressed and the trim bar rides up.
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () => confirmComposerBack(context),
          ),
          title: Text(
            draft.isEditing ? 'Hariri Video' : 'Status ya Video',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: _continue,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    'Endelea',
                    style: TextStyle(
                      color: Color(0xFF1B1917),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              // Editing banner (if in edit mode)
              if (draft.isEditing)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _editingBanner(),
                ),

              // CANVAS — dominant, ~58% of vertical space
              Expanded(
                flex: 58,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    // 3px bottom gap to the control row
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 3),
                    child: _previewCanvas(draft),
                  ),
                ),
              ),

              // BOTTOM CONTROLS — ~42%
              Expanded(
                flex: 42,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // CONTROLS ROW (Play/Pause left, Undo/Redo right)
                    _controlRow(draft.hasImage),

                    // 3px gap between the control row and the video trimmer
                    const SizedBox(height: 3),

                    // TRIMMERS (Video & Audio)
                    _trimBarSection(draft),

                    if (draft.hasImage) ...[
                      // Text overlays chips
                      _textOverlaysRow(),
                    ],

                    const Spacer(),

                    // TOOL DOCK (Caption, Logo, Song, Quick Tags, Volume)
                    _toolDock(draft.hasImage),
                    // Removed SizedBox(height: 20) to fix 15px overflow
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _trimBarSection(CreatePostProvider draft) {
    if (!draft.hasImage || _videoDuration == Duration.zero) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ValueListenableBuilder<double>(
            valueListenable: _positionNotifier,
            builder: (_, pos, _) => VideoTrimBar(
              duration: _videoDuration,
              videoFilePath: _videoFilePath,
              barWidth: MediaQuery.of(context).size.width - 32,
              startFraction: _trimStart,
              endFraction: _trimEnd,
              positionFraction: pos,
              onFramesLoaded: () {
                if (mounted) setState(() => _framesLoaded = true);
              },
              onDragStart: () {
                _recordHistory();
                if (mounted) setState(() => _isDraggingTrim = true);
              },
              onDragEnd: () {
                if (mounted) {
                  setState(() => _isDraggingTrim = false);
                  _syncEditsToProvider();
                }
              },
              onChanged: (s, e) {
                setState(() {
                  _trimStart = s;
                  _trimEnd = e;
                });
                _syncEditsToProvider();
              },
            ),
          ),
        ),
        if (_musicFilePath != null && _audioDuration > Duration.zero) ...[
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AudioTrackSlider(
              videoDuration: _videoDuration,
              audioDuration: _audioDuration,
              audioStartOffset: _audioStartOffset,
              barWidth: MediaQuery.of(context).size.width - 32,
              handleWidth: 22.0,
              trimStart: _trimStart,
              trimEnd: _trimEnd,
              positionNotifier: _positionNotifier,
              onChanged: (offset) {
                setState(() => _audioStartOffset = offset);
                _syncEditsToProvider();
              },
              onDragStart: _recordHistory,
            ),
          ),
        ],
        // 3px gap between the (last) trimmer and whatever follows
        const SizedBox(height: 3),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // CANVAS (preview + overlay controls)
  // ---------------------------------------------------------------------

  Widget _editingBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.statusPending.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'Unaendelea kuhariri post ya awali. Video ya awali itahifadhiwa usipochagua nyingine.',
        style: TextStyle(
          color: AppColors.statusPending,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _previewCanvas(CreatePostProvider draft) {
    final hasVideo = draft.hasImage && draft.imageBytes != null;

    return Align(
      alignment: Alignment.topCenter,
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            color: Colors.black,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasVideo)
                  VideoEditorPreview(
                    key: _previewKey,
                    videoBytes: draft.imageBytes!,
                    musicFilePath: _musicFilePath,
                    audioStartOffset: _audioStartOffset,
                    watermarkImagePath: _watermarkImagePath,
                    watermarkPosition: _watermarkPosition,
                    watermarkScale: _watermarkScale,
                    watermarkResetTick: _watermarkResetTick,
                    onWatermarkChanged: (pos, scale) {
                      // Update the parent's persisted values WITHOUT rebuilding the
                      // screen — the preview manages its own live rendering. The
                      // provider's auto-save is already debounced (500ms).
                      _watermarkPosition = pos;
                      _watermarkScale = scale;
                      _syncEditsToProvider();
                    },
                    onWatermarkDragStart: _recordHistory,
                    shouldPlay: _framesLoaded,
                    isDraggingTrim: _isDraggingTrim,
                    originalVolume: _originalVolume,
                    musicVolume: _musicVolume,
                    isPlayingNotifier: _isPlayingNotifier,
                    trimStart: _trimStart,
                    trimEnd: _trimEnd,
                    onDurationLoaded: (d) {
                      if (mounted) setState(() => _videoDuration = d);
                    },
                    onFileReady: (path) {
                      if (mounted) setState(() => _videoFilePath = path);
                    },
                    onPositionChanged: (f) {
                      // No setState — only the ValueNotifier updates, so only
                      // VideoTrimBar rebuilds, not the whole screen.
                      _positionNotifier.value = f;
                    },
                  )
                else
                  const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _textOverlaysRow() {
    if (_textOverlays.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var i = 0; i < _textOverlays.length; i++)
            InputChip(
              label: Text(
                _textOverlays[i].text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              avatar: const Icon(Icons.title, size: 16),
              backgroundColor: Colors.black.withValues(alpha: 0.55),
              labelStyle: const TextStyle(color: Colors.white),
              onDeleted: () {
                _recordHistory();
                setState(() => _textOverlays.removeAt(i));
                _syncEditsToProvider();
              },
              deleteIconColor: Colors.white70,
            ),
        ],
      ),
    );
  }

  void _onMusicRemoved() {
    _recordHistory();
    setState(() {
      _musicFilePath = null;
      _musicFileName = null;
      _musicId = null;
      _audioDuration = Duration.zero;
      _audioStartOffset = Duration.zero;
    });
    _syncEditsToProvider();
  }

  // ---------------------------------------------------------------------
  // CONTROLS & TOOL DOCK
  // ---------------------------------------------------------------------

  Widget _controlRow(bool hasVideo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // LEFT: Play/Pause button
          ValueListenableBuilder<bool>(
            valueListenable: _isPlayingNotifier,
            builder: (ctx, isPlaying, _) {
              return InkWell(
                onTap: hasVideo
                    ? () => _previewKey.currentState?.togglePlayPause()
                    : null,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              );
            },
          ),

          // CENTER: Empty space now (Badilisha removed)
          const Spacer(),

          // RIGHT: Undo + Redo
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: AppColors.border, width: 1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.undo, color: Colors.white70, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed: _canUndo ? _undo : null,
                ),
                Container(width: 1, height: 16, color: Colors.white24),
                IconButton(
                  icon: const Icon(Icons.redo, color: Colors.white70, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed: _canRedo ? _redo : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openVolumeDrawer() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Sauti',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 32),
                Column(
                  children: [
                    _volumeSliderRow(
                      label: 'Sauti Halisi',
                      value: _originalVolume,
                      onChanged: (val) {
                        setModalState(() => _originalVolume = val);
                        setState(() {});
                        _syncEditsToProvider();
                      },
                      onChangeStart: _recordHistory,
                    ),
                    const SizedBox(height: 24),
                    _volumeSliderRow(
                      label: 'Muziki',
                      value: _musicVolume,
                      onChanged: (val) {
                        setModalState(() => _musicVolume = val);
                        setState(() {});
                        _syncEditsToProvider();
                      },
                      onChangeStart: _recordHistory,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _volumeSliderRow({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    VoidCallback? onChangeStart,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 18,
            thumbShape: const _TrimmerHandleThumbShape(
              thumbWidth: 18,
              thumbHeight: 40,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.border,
            trackShape: const RoundedRectSliderTrackShape(),
          ),
          child: Slider(
            value: value,
            onChanged: onChanged,
            onChangeStart: (_) => onChangeStart?.call(),
          ),
        ),
      ],
    );
  }

  Widget _toolDock(bool hasVideo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 1),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _editorTool(
                const Icon(
                  Icons.closed_caption_outlined,
                  size: 24,
                  color: AppColors.primary,
                ),
                'Caption',
                onTap: _openCaptionDrawer,
              ),
              const SizedBox(width: 12),
              _editorTool(
                _watermarkImagePath != null
                    ? Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: FileImage(File(_watermarkImagePath!)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.image_outlined,
                        size: 24,
                        color: AppColors.primary,
                      ),
                'Logo',
                onTap: _handleLogoClick,
              ),
              const SizedBox(width: 12),
              _editorTool(
                _musicId != null
                    ? Container(
                        width: 24,
                        height: 24,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: QueryArtworkWidget(
                          id: _musicId!,
                          type: ArtworkType.AUDIO,
                          artworkFit: BoxFit.cover,
                          nullArtworkWidget: const Icon(
                            Icons.music_note_outlined,
                            size: 24,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.music_note_outlined,
                        size: 24,
                        color: AppColors.primary,
                      ),
                'Muziki',
                onTap: _handleSongClick,
              ),
              const SizedBox(width: 12),
              _editorTool(
                const Icon(Icons.tag, size: 24, color: AppColors.primary),
                'Quick Tags',
                onTap: _openQuickTagsSheet,
              ),
              const SizedBox(width: 12),
              _editorTool(
                const Icon(Icons.volume_up, size: 24, color: AppColors.primary),
                'Volume',
                onTap: hasVideo ? _openVolumeDrawer : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogoClick() {
    if (_watermarkImagePath == null) {
      _pickWatermark();
    } else {
      _showLogoPopup();
    }
  }

  void _handleSongClick() {
    if (_musicFilePath == null) {
      _openMusicPicker();
    } else {
      _showSongPopup();
    }
  }

  void _showLogoPopup() {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (ctx) => Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 74, left: 20, right: 20),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                      image: _watermarkImagePath != null
                          ? DecorationImage(
                              image: FileImage(File(_watermarkImagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _watermarkImagePath == null
                        ? const Icon(
                            Icons.image,
                            size: 16,
                            color: Colors.white54,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Logo/Watermark',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.sync, color: Colors.white),
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _pickWatermark();
                    },
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.redAccent),
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _recordHistory();
                      setState(() {
                        _watermarkImagePath = null;
                        _watermarkPosition = const Offset(20, 20);
                        _watermarkScale = 1.0;
                      });
                      _watermarkResetTick++;
                      _syncEditsToProvider();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSongPopup() {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (ctx) => Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 74, left: 20, right: 20),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: _musicId != null
                        ? QueryArtworkWidget(
                            id: _musicId!,
                            type: ArtworkType.AUDIO,
                            artworkFit: BoxFit.cover,
                            nullArtworkWidget: const Icon(
                              Icons.music_note,
                              size: 16,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.music_note,
                            size: 16,
                            color: Colors.white,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _musicFileName ?? 'Muziki',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.sync, color: Colors.white),
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _openMusicPicker();
                    },
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.redAccent),
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _onMusicRemoved();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _editorTool(Widget iconWidget, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Open caption as a bottom drawer
  Future<void> _openCaptionDrawer() async {
    final draft = context.read<CreatePostProvider>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Caption',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 12),
            // Quick tags — starts blank with just a "+" add chip; saved tags
            // show by their title and insert their content into the caption.
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...context.watch<QuickTagsProvider>().tags.map(
                  (tag) => ActionChip(
                    label: Text(tag.title),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _insertText(tag.content),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _captionController,
              maxLines: 4,
              maxLength: 700,
              autofocus: true,
              onChanged: draft.setCaption,
              decoration: const InputDecoration(
                hintText: 'Andika maelezo ya video yako hapa…',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Open the reusable quick-tag library as a compact bottom sheet. Starts with
  // just a "+" add chip; saved global tags appear as title chips. Tapping a tag
  // inserts its saved content into the caption.
  Future<void> _openQuickTagsSheet() async {
    final tags = context.read<QuickTagsProvider>();
    await tags.load();
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Quick Tags',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 14),
            _quickTagCollection(sheetCtx),
          ],
        ),
      ),
    );
  }

  // The horizontal quick-tag UI shared by the tool dock and caption drawer:
  // a "+" add chip followed by the user's saved tags as title chips.
  Widget _quickTagCollection(BuildContext sheetCtx) {
    return Consumer<QuickTagsProvider>(
      builder: (ctx, tags, _) => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          ActionChip(
            avatar: const Icon(Icons.add, size: 18),
            label: const Text('Ongeza Tag'),
            onPressed: () => _openAddQuickTagDrawer(),
          ),
          ...tags.tags.map(
            (tag) => InputChip(
              label: Text(tag.title),
              onPressed: () {
                _insertText(tag.content);
                Navigator.pop(sheetCtx);
              },
              onDeleted: () {
                tags.remove(tag.title);
              },
              deleteIconColor: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // Drawer to add a new global quick tag: a short title (chip label) and the
  // content that gets inserted when the tag is used.
  Future<void> _openAddQuickTagDrawer() async {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Ongeza Quick Tag',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: titleCtrl,
              maxLength: 30,
              decoration: const InputDecoration(
                labelText: 'Jina (kwa chip)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contentCtrl,
              maxLines: 3,
              maxLength: 200,
              decoration: const InputDecoration(
                labelText: 'Maandishi ya kuingiza',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final title = titleCtrl.text.trim();
                  if (title.isEmpty) return;
                  await context.read<QuickTagsProvider>().add(
                    QuickTag(title: title, content: contentCtrl.text),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Hifadhi'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Muziki: directly open the device audio picker sheet
  Future<void> _openMusicPicker() async {
    final picked = await showDeviceAudioPicker(context);
    if (picked != null) {
      final player = AudioPlayer();
      await player.setSourceDeviceFile(picked.path);
      final duration = await player.getDuration();
      await player.dispose();

      _recordHistory();
      setState(() {
        _musicFilePath = picked.path;
        _musicFileName = picked.name;
        _musicId = picked.id;
        _audioDuration = duration ?? Duration.zero;
        _audioStartOffset = Duration.zero;
      });
      _syncEditsToProvider();
    }
  }

  Future<void> _pickWatermark() async {
    // No permission gate: image_picker uses the system Photo Picker, which
    // requires no runtime permissions on any Android version (requesting
    // storage/media permissions here dead-ends on every API level).
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final dir = await getApplicationDocumentsDirectory();
      final newFile = File(
        '${dir.path}/watermark_${DateTime.now().microsecondsSinceEpoch}.jpg',
      );
      await File(picked.path).copy(newFile.path);

      _recordHistory();
      if (mounted) {
        setState(() {
          _watermarkImagePath = newFile.path;
          _watermarkPosition = const Offset(20, 20);
          _watermarkScale = 1.0;
        });
        _watermarkResetTick++;
        _syncEditsToProvider();
      }
    }
  }
}

class _TrimmerHandleThumbShape extends SliderComponentShape {
  final double thumbWidth;
  final double thumbHeight;

  const _TrimmerHandleThumbShape({
    this.thumbWidth = 18.0,
    this.thumbHeight = 40.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(thumbWidth, thumbHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final RRect thumbRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: thumbWidth, height: thumbHeight),
      const Radius.circular(6), // Gold pill radius
    );

    // Draw gold background
    final Paint goldPaint = Paint()..color = const Color(0xFFC99A43);
    canvas.drawRRect(thumbRRect, goldPaint);

    // Draw 3 vertical grip lines
    final Paint gripPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final double startY = center.dy;

    // Middle line (taller)
    canvas.drawLine(
      Offset(center.dx, startY - 8),
      Offset(center.dx, startY + 8),
      gripPaint,
    );

    // Left line (shorter)
    canvas.drawLine(
      Offset(center.dx - 3.5, startY - 5),
      Offset(center.dx - 3.5, startY + 5),
      gripPaint,
    );

    // Right line (shorter)
    canvas.drawLine(
      Offset(center.dx + 3.5, startY - 5),
      Offset(center.dx + 3.5, startY + 5),
      gripPaint,
    );
  }
}

/// Immutable capture of every editable value in the video status editor, used
/// by the Undo/Redo stacks to restore the full editor state.
class _EditorSnapshot {
  final double trimStart;
  final double trimEnd;
  final String? musicFilePath;
  final String? musicFileName;
  final int? musicId;
  final Duration audioStartOffset;
  final Duration audioDuration;
  final double originalVolume;
  final double musicVolume;
  final String? watermarkImagePath;
  final Offset watermarkPosition;
  final double watermarkScale;
  final List<VideoTextOverlay> textOverlays;

  const _EditorSnapshot({
    required this.trimStart,
    required this.trimEnd,
    required this.musicFilePath,
    required this.musicFileName,
    required this.musicId,
    required this.audioStartOffset,
    required this.audioDuration,
    required this.originalVolume,
    required this.musicVolume,
    required this.watermarkImagePath,
    required this.watermarkPosition,
    required this.watermarkScale,
    required this.textOverlays,
  });
}

/// Shows a non-dismissible progress card overlay during inline video render.
/// Bound to [progress], so the card updates its percentage live without
/// rebuilding the whole status screen. Used by Endelea so rendering happens in
/// place (no navigation to a separate render screen).
Future<void> showRenderProgressDialog({
  required BuildContext context,
  required ValueNotifier<double?> progress,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (ctx) => PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ValueListenableBuilder<double?>(
            valueListenable: progress,
            builder: (ctx, value, _) {
              final pct = value == null ? null : (value * 100).round();
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    value == null
                        ? 'Inatayarisha video kwenye kifaa…'
                        : 'Inakamilisha video… $pct%',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (value != null) ...[
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 8,
                        backgroundColor: AppColors.surfaceMuted,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'Usiondoke ukurasa huu — inachakatwa kwenye simu yako.',
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}
