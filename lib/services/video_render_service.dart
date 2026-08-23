import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../models/video_composition_model.dart';
import 'api_client.dart';

/// Polling period used by [waitForRender].
const videoRenderPollInterval = Duration(seconds: 5);

/// Result of polling a render job.
class VideoRenderResult {
  const VideoRenderResult({
    required this.jobId,
    required this.status,
    this.outputUrl,
    this.error,
  });

  final int jobId;
  final String status;
  final String? outputUrl;
  final String? error;

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isFinished => isCompleted || isFailed;

  factory VideoRenderResult.fromJson(Map<String, dynamic> json) {
    return VideoRenderResult(
      jobId: (json['job_id'] ?? json['jobId']) as int? ?? 0,
      status: (json['status'] as String?) ?? 'unknown',
      outputUrl: json['output_url'] as String?,
      error: json['error'] as String?,
    );
  }
}

/// Talks to `POST /api/v1/video/*` — uploads raw media assets, submits a
/// [VideoComposition] for cloud rendering and polls the job until it finishes.
///
/// The app never processes video itself: the backend (JSON2Video) renders it
/// and returns a downloadable `.mp4`.
class VideoRenderService {
  VideoRenderService({ApiClient? client}) : _api = client ?? ApiClient.instance;

  final ApiClient _api;

  /// Uploads a raw asset (source video, watermark PNG or background music) and
  /// returns its public URL to embed in a composition.
  Future<String> uploadAsset({
    required Uint8List bytes,
    required String filename,
    String mimeType = 'video/mp4',
  }) async {
    try {
      final form = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: filename,
          contentType: DioMediaType.parse(mimeType),
        ),
      });
      final res = await _api.dio.post('/v1/video/asset', data: form);
      final data = res.data as Map<String, dynamic>;
      final url = data['url'] as String?;
      if (url == null || url.isEmpty) {
        throw 'Upload haukurejesha URL';
      }
      return url;
    } on DioException {
      rethrow;
    }
  }

  /// Submits a composition for cloud rendering; returns the new job id.
  Future<int> startRender(VideoComposition composition) async {
    try {
      final res = await _api.dio.post('/v1/video/render', data: composition.toJson());
      final data = res.data as Map<String, dynamic>;
      final jobId = data['job_id'] ?? data['jobId'];
      return (jobId as num?)?.toInt() ?? 0;
    } on DioException {
      rethrow;
    }
  }

  /// Fetches the current status of a render job.
  Future<VideoRenderResult> getStatus(int jobId) async {
    try {
      final res = await _api.dio.get('/v1/video/render/status', queryParameters: {
        'job_id': jobId,
      });
      return VideoRenderResult.fromJson(res.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  /// Polls until the job completes/fails or [timeout] elapses.
  Future<VideoRenderResult> waitForRender(
    int jobId, {
    Duration timeout = const Duration(minutes: 10),
    Duration interval = videoRenderPollInterval,
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (true) {
      final result = await getStatus(jobId);
      if (result.isFinished) return result;
      if (DateTime.now().isAfter(deadline)) {
        return VideoRenderResult(
          jobId: jobId,
          status: 'timeout',
          error: 'Muda wa render umeisha',
        );
      }
      await Future.delayed(interval);
    }
  }
}
