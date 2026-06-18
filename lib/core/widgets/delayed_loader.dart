import 'dart:async';

import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class DelayedLoader extends StatefulWidget {
  final Duration delay;
  final double? size;
  final double? strokeWidth;
  final Color? color;

  const DelayedLoader({
    super.key,
    this.delay = const Duration(milliseconds: 300),
    this.size,
    this.strokeWidth,
    this.color,
  });

  @override
  State<DelayedLoader> createState() => _DelayedLoaderState();
}

class _DelayedLoaderState extends State<DelayedLoader> {
  bool _showLoader = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () {
      if (mounted) {
        setState(() {
          _showLoader = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showLoader) {
      return const SizedBox.shrink();
    }

    final loader = CircularProgressIndicator(
      strokeWidth: widget.strokeWidth ?? 4.0,
      color: widget.color,
      semanticsLabel: AppLocalizations.of(context).semanticsLoading,
    );

    if (widget.size != null) {
      return SizedBox(width: widget.size, height: widget.size, child: loader);
    }

    return loader;
  }
}
