import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Result of picking (and optionally trimming) a device song.
class PickedDeviceAudio {
  const PickedDeviceAudio({required this.path, required this.name, this.id});

  final String path;
  final String name;
  final int? id;
}

/// Requests the storage/audio read permission, then opens a ~85%-height
/// drawer listing every song on the device. The user can search by typing and
/// trim the selected track (via FFmpeg) before it is returned.
///
/// Returns null when cancelled or when permission was not granted.
Future<PickedDeviceAudio?> showDeviceAudioPicker(BuildContext context) async {
  final granted = await _requestAudioReadPermission();
  if (!granted) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Huna ruhusa ya kusoma wimbo. Imewasha kutoka Mipangilio.'),
        ),
      );
    }
    return null;
  }

  if (!context.mounted) return null;
  return showModalBottomSheet<PickedDeviceAudio>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => FractionallySizedBox(
      heightFactor: 0.85,
      child: const _DeviceAudioSheet(),
    ),
  );
}

/// Asks for `READ_MEDIA_AUDIO` on Android 13+ and `READ_EXTERNAL_STORAGE`
/// below, since on_audio_query cannot read the MediaStore without one of those.
Future<bool> _requestAudioReadPermission() async {
  try {
    final device = await OnAudioQuery().queryDeviceInfo();
    final sdk = device.version;
    final permission = sdk >= 33 ? Permission.audio : Permission.storage;

    var status = await permission.status;
    if (!status.isGranted) {
      status = await permission.request();
    }
    return status.isGranted;
  } catch (_) {
    return false;
  }
}

class _DeviceAudioSheet extends StatefulWidget {
  const _DeviceAudioSheet();

  @override
  State<_DeviceAudioSheet> createState() => _DeviceAudioSheetState();
}

class _DeviceAudioSheetState extends State<_DeviceAudioSheet> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final TextEditingController _searchController = TextEditingController();

  List<SongModel> _songs = const [];
  List<SongModel> _filtered = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final songs = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
      );
      final mp3Songs = songs.where((s) => s.fileExtension.toLowerCase() == 'mp3').toList();
      if (!mounted) return;
      setState(() {
        _songs = mp3Songs;
        _filtered = mp3Songs;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Imeshindikana kupakia wimbo. Jaribu tena.';
      });
    }
  }

  void _onSearchChanged(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _filtered = _songs);
      return;
    }
    setState(() {
      _filtered = _songs.where((s) {
        return s.title.toLowerCase().contains(q) ||
            (s.artist?.toLowerCase().contains(q) ?? false) ||
            (s.album?.toLowerCase().contains(q) ?? false) ||
            s.displayName.toLowerCase().contains(q);
      }).toList();
    });
  }

  void _close() => Navigator.of(context).pop();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildList();
  }

  // ---------------------------------------------------------------------
  // LIST STEP
  // ---------------------------------------------------------------------

  Widget _buildList() {
    return Column(
      key: const ValueKey('list'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 4),
          child: Row(
            children: [
              Expanded(
                child: Text('Chagua Wimbo', style: AppTextStyles.sectionHeader),
              ),
              IconButton(
                tooltip: 'Funga',
                onPressed: _close,
                icon: const Icon(Icons.close),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Tafuta wimbo…',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              filled: true,
              fillColor: AppColors.surfaceMuted,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildSongArea()),
      ],
    );
  }

  Widget _buildSongArea() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadSongs,
              child: const Text('Jaribu tena'),
            ),
          ],
        ),
      );
    }
    if (_filtered.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isEmpty
              ? 'Hakuna wimbo kwenye kifaa.'
              : 'Hakuna matokeo ya tafuta.',
          style: AppTextStyles.bodyMedium,
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _filtered.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final song = _filtered[index];
        return ListTile(
          leading: _Artwork(id: song.id, query: _audioQuery),
          title: Text(
            song.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            [
              if (song.artist != null && song.artist!.isNotEmpty) song.artist!,
              if (song.duration != null && song.duration! > 0)
                _formatDuration(song.duration!),
            ].join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption,
          ),
          onTap: () {
            Navigator.of(context).pop(PickedDeviceAudio(
              path: song.data,
              name: song.displayNameWOExt.isNotEmpty
                  ? song.displayNameWOExt
                  : song.displayName,
              id: song.id,
            ));
          },
        );
      },
    );
  }
}

String _formatDuration(int millis) {
  final totalSec = (millis / 1000).round();
  final m = (totalSec ~/ 60).toString().padLeft(2, '0');
  final s = (totalSec % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// Lazily builds the song's embedded album art, with an in-flight guard.
class _Artwork extends StatefulWidget {
  const _Artwork({required this.id, required this.query});

  final int id;
  final OnAudioQuery query;

  @override
  State<_Artwork> createState() => _ArtworkState();
}

class _ArtworkState extends State<_Artwork> {
  Uint8List? _bytes;
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) _fetch();
  }

  Future<void> _fetch() async {
    try {
      final bytes = await widget.query.queryArtwork(
        widget.id,
        ArtworkType.AUDIO,
        size: 200,
        format: ArtworkFormat.JPEG,
      );
      if (mounted) {
        setState(() {
          _bytes = bytes;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loading && _bytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          _bytes!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        ),
      );
    }
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.music_note, size: 20, color: AppColors.textSecondary),
    );
  }
}