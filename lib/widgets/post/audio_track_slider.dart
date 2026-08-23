import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AudioTrackSlider extends StatefulWidget {
  final Duration videoDuration;
  final Duration audioDuration;
  final Duration audioStartOffset;
  final double barWidth;
  final double handleWidth;
  final double trimStart;
  final double trimEnd;
  final ValueNotifier<double>? positionNotifier;
  final ValueChanged<Duration> onChanged;
  final VoidCallback? onDragStart;

  const AudioTrackSlider({
    super.key,
    required this.videoDuration,
    required this.audioDuration,
    required this.audioStartOffset,
    required this.barWidth,
    required this.handleWidth,
    required this.trimStart,
    required this.trimEnd,
    this.positionNotifier,
    required this.onChanged,
    this.onDragStart,
  });

  @override
  State<AudioTrackSlider> createState() => _AudioTrackSliderState();
}

class _AudioTrackSliderState extends State<AudioTrackSlider> {
  @override
  Widget build(BuildContext context) {
    if (widget.videoDuration == Duration.zero || widget.audioDuration == Duration.zero) {
      return const SizedBox.shrink();
    }

    final double innerW = widget.barWidth - widget.handleWidth * 2;
    final double activeStartX = widget.handleWidth + widget.trimStart * innerW;
    final double activeEndX = widget.handleWidth + widget.trimEnd * innerW;
    final double activeWidth = activeEndX - activeStartX;

    if (activeWidth <= 0) return const SizedBox.shrink();

    final double trimmedVideoDurationMs = widget.videoDuration.inMilliseconds * (widget.trimEnd - widget.trimStart);
    final double ratio = widget.audioDuration.inMilliseconds / trimmedVideoDurationMs;
    final double totalWaveWidth = activeWidth * ratio;
    
    double currentOffsetPx = (widget.audioStartOffset.inMilliseconds / widget.audioDuration.inMilliseconds) * totalWaveWidth;

    return Container(
      width: widget.barWidth,
      height: 48,
      alignment: Alignment.centerLeft,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: activeStartX,
            width: activeWidth,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onHorizontalDragStart: (_) => widget.onDragStart?.call(),
              onHorizontalDragUpdate: (details) {
                final newOffsetPx = currentOffsetPx - details.delta.dx;
                final maxOffsetPx = max(0.0, totalWaveWidth - activeWidth);
                final clampedOffsetPx = newOffsetPx.clamp(0.0, maxOffsetPx);
                
                final newStartMs = (clampedOffsetPx / totalWaveWidth) * widget.audioDuration.inMilliseconds;
                widget.onChanged(Duration(milliseconds: newStartMs.round()));
              },
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (widget.positionNotifier != null)
                      ValueListenableBuilder<double>(
                        valueListenable: widget.positionNotifier!,
                        builder: (context, fraction, _) {
                          final playheadPx = widget.handleWidth + fraction * innerW;
                          final localPlayheadX = playheadPx - activeStartX;
                          final waveformPlayheadX = localPlayheadX + currentOffsetPx;

                          return Positioned(
                            left: -currentOffsetPx,
                            top: 0,
                            bottom: 0,
                            child: CustomPaint(
                              size: Size(totalWaveWidth, 48),
                              painter: _ProceduralWaveformPainter(
                                seed: widget.audioDuration.inMilliseconds,
                                playheadX: waveformPlayheadX,
                              ),
                            ),
                          );
                        },
                      )
                    else
                      Positioned(
                        left: -currentOffsetPx,
                        top: 0,
                        bottom: 0,
                        child: CustomPaint(
                          size: Size(totalWaveWidth, 48),
                          painter: _ProceduralWaveformPainter(
                            seed: widget.audioDuration.inMilliseconds,
                            playheadX: 0,
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

class _ProceduralWaveformPainter extends CustomPainter {
  final int seed;
  final double playheadX;

  _ProceduralWaveformPainter({
    required this.seed,
    required this.playheadX,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);
    const double barWidth = 3.0;
    const double spacing = 2.0;
    final int barCount = (size.width / (barWidth + spacing)).floor();

    for (int i = 0; i < barCount; i++) {
      final x = i * (barWidth + spacing);
      final envelope = sin((i / barCount) * pi * 8) * 0.3 + 0.7;
      final noise = random.nextDouble() * 0.6 + 0.4;
      final barHeight = size.height * envelope * noise * 0.7;
      
      final top = (size.height - barHeight) / 2;
      final bottom = top + barHeight;

      final paint = Paint()
        ..color = x <= playheadX ? AppColors.primary : const Color(0xFF888888)
        ..strokeWidth = barWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(x, top), Offset(x, bottom), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ProceduralWaveformPainter oldDelegate) {
    return oldDelegate.seed != seed || oldDelegate.playheadX != playheadX;
  }
}

