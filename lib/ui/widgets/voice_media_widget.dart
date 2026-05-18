import 'package:flutter/material.dart';

/// UI-only voice message player.
/// Wiring to an actual audio player (e.g. just_audio) is left to the
/// integration layer — this widget only handles visual state.
class VoiceMediaWidget extends StatefulWidget {
  final bool isOutgoing;
  final Duration duration;

  const VoiceMediaWidget({
    super.key,
    this.isOutgoing = false,
    this.duration = const Duration(seconds: 12),
  });

  @override
  State<VoiceMediaWidget> createState() => _VoiceMediaWidgetState();
}

class _VoiceMediaWidgetState extends State<VoiceMediaWidget> {
  bool _playing = false;
  final double _progress = 0;

  void _toggle() => setState(() => _playing = !_playing);

  @override
  Widget build(BuildContext context) {
    final fg = widget.isOutgoing ? Colors.white : Theme.of(context).colorScheme.primary;
    final fgSub = widget.isOutgoing ? Colors.white70 : Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    final trackBg = widget.isOutgoing ? Colors.white24 : Theme.of(context).colorScheme.primary.withOpacity(0.15);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Play/pause button
        GestureDetector(
          onTap: _toggle,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: fg.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: fg, size: 20),
          ),
        ),
        const SizedBox(width: 10),
        // Waveform + scrubber
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WaveformBar(progress: _progress, color: fg, trackColor: trackBg),
              const SizedBox(height: 4),
              Text(
                _formatDuration(widget.duration),
                style: TextStyle(fontSize: 10, color: fgSub),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

/// Simple decorative waveform bar (static visual, not real audio data).
class _WaveformBar extends StatelessWidget {
  final double progress;
  final Color color;
  final Color trackColor;

  const _WaveformBar({required this.progress, required this.color, required this.trackColor});

  static const _heights = [4.0, 10.0, 6.0, 14.0, 8.0, 12.0, 5.0, 14.0, 9.0, 7.0, 12.0, 6.0, 10.0, 8.0, 5.0];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_heights.length, (i) {
          final filled = i / _heights.length <= progress;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Container(
              width: 3,
              height: _heights[i],
              decoration: BoxDecoration(
                color: filled ? color : trackColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
