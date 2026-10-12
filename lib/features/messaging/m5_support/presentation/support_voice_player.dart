/// ******************* FILE INFO *******************
/// File Name: support_voice_player.dart
/// Purpose: Plays a voice note the admin sent in Knowticed Support
///          (24/9/2026) — same player as the admin dashboard's Messages
///          bubble (knowticed_admin › help_voice_player.dart): play / pause,
///          seekable bar, remaining / total time, 1x · 1.5x · 2x. Streams the
///          .m4a from its URL with `audioplayers` on every platform.
/// Module: messaging / m5_support / presentation
/// Author: Amr Mesbah
/// Created: 24/9/2026.

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class SupportVoicePlayer extends StatefulWidget {
  const SupportVoicePlayer({super.key, required this.url, this.color});

  final String url;

  /// Icon / bar / text colour; AppColors.text by default.
  final Color? color;

  @override
  State<SupportVoicePlayer> createState() => _SupportVoicePlayerState();
}

class _SupportVoicePlayerState extends State<SupportVoicePlayer> {
  /// Only one voice note plays at a time — starting one pauses the other.
  static _SupportVoicePlayerState? _playing;

  static const List<double> _rates = [1, 1.5, 2];

  AudioPlayer? _player;
  final List<StreamSubscription<dynamic>> _subs = [];
  bool _sourceSet = false;
  bool _isPlaying = false;
  bool _loading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  int _rateIndex = 0;

  AudioPlayer _ensurePlayer() {
    if (_player != null) return _player!;
    final p = AudioPlayer();
    _subs
      ..add(p.onDurationChanged.listen((d) {
        if (mounted) setState(() => _duration = d);
      }))
      ..add(p.onPositionChanged.listen((d) {
        if (mounted) setState(() => _position = d);
      }))
      ..add(p.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _position = Duration.zero;
          });
        }
      }));
    return _player = p;
  }

  Future<void> _toggle() async {
    if (widget.url.isEmpty || _loading) return;
    final p = _ensurePlayer();
    if (_isPlaying) {
      await p.pause();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }
    if (_playing != null && _playing != this) await _playing!._pauseFromOther();
    _playing = this;
    try {
      if (!_sourceSet) {
        setState(() => _loading = true);
        await p.setSource(UrlSource(widget.url));
        _sourceSet = true;
        final d = await p.getDuration();
        if (d != null && d > Duration.zero) _duration = d;
        await p.setPlaybackRate(_rates[_rateIndex]);
      }
      await p.resume();
      if (mounted) setState(() => _isPlaying = true);
    } catch (e) {
      debugPrint('[SupportVoicePlayer] $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pauseFromOther() async {
    await _player?.pause();
    if (mounted) setState(() => _isPlaying = false);
  }

  Future<void> _nextRate() async {
    setState(() => _rateIndex = (_rateIndex + 1) % _rates.length);
    await _player?.setPlaybackRate(_rates[_rateIndex]);
  }

  Future<void> _seek(double ratio) async {
    if (_duration <= Duration.zero) return;
    final to = Duration(
        milliseconds: (_duration.inMilliseconds * ratio.clamp(0.0, 1.0)).round());
    setState(() => _position = to);
    await _player?.seek(to);
  }

  String _fmt(Duration d) =>
      '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  String get _rateLabel {
    final r = _rates[_rateIndex];
    return '${r == r.roundToDouble() ? r.toInt() : r}x';
  }

  @override
  void dispose() {
    if (_playing == this) _playing = null;
    for (final s in _subs) {
      s.cancel();
    }
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.text;
    final total = _duration.inMilliseconds;
    final progress =
        total <= 0 ? 0.0 : (_position.inMilliseconds / total).clamp(0.0, 1.0);
    final left = _duration - _position;
    final timeText = _isPlaying || _position > Duration.zero
        ? _fmt(left.isNegative ? Duration.zero : left)
        : (_duration > Duration.zero ? _fmt(_duration) : '--:--');

    return SizedBox(
      width: 240.w,
      child: Row(
        children: [
          // ── Play / pause ───────────────────────────────────────────────
          InkWell(
            onTap: _toggle,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 30.sp,
              height: 30.sp,
              child: _loading
                  ? Padding(
                      padding: EdgeInsets.all(7.sp),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: color),
                    )
                  : Icon(
                      _isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 26.sp,
                      color: color),
            ),
          ),
          SizedBox(width: 6.sp),
          // ── Seekable progress bar ─────────────────────────────────────
          Expanded(
            child: LayoutBuilder(builder: (context, c) {
              final width = c.maxWidth;
              final rtl = Directionality.of(context) == TextDirection.rtl;
              void seekAt(Offset local) {
                if (width <= 0) return;
                var r = local.dx / width;
                if (rtl) r = 1 - r;
                _seek(r);
              }

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) => seekAt(d.localPosition),
                onHorizontalDragUpdate: (d) => seekAt(d.localPosition),
                child: SizedBox(
                  height: 24.sp,
                  child: Stack(
                    alignment: AlignmentDirectional.centerStart,
                    children: [
                      Container(
                        height: 4.sp,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 4.sp,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(2 * progress - 1, 0),
                        child: Container(
                          width: 10.sp,
                          height: 10.sp,
                          decoration: BoxDecoration(
                              color: color, shape: BoxShape.circle),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          SizedBox(width: 8.sp),
          // ── Time + speed ──────────────────────────────────────────────
          Text(timeText,
              style: StyleText.fontSize12Weight500.copyWith(color: color)),
          SizedBox(width: 6.sp),
          InkWell(
            onTap: _nextRate,
            borderRadius: BorderRadius.circular(4.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 1.sp),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(_rateLabel,
                  style:
                      StyleText.fontSize10Weight400.copyWith(color: color)),
            ),
          ),
        ],
      ),
    );
  }
}
