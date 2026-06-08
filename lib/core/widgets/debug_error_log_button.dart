import 'package:edubadges/core/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DebugErrorLogButton extends StatelessWidget {
  final Object? error;
  final StackTrace? stackTrace;
  final String? debugContext;

  const DebugErrorLogButton({
    super.key,
    this.error,
    this.stackTrace,
    this.debugContext,
  });

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }
    return TextButton(
      onPressed: _logError,
      child: const Text('Log error to console'),
    );
  }

  void _logError() {
    if (error != null) {
      logger.e('Error state', error: error, stackTrace: stackTrace);
      return;
    }
    if (debugContext != null) {
      logger.w('Error state: $debugContext');
      return;
    }
    logger.w('Error state (no error details provided)');
  }
}
