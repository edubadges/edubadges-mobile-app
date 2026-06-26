import 'package:flutter/material.dart';

typedef DeferredLibraryLoader = Future<void> Function();

class DeferredWidget extends StatefulWidget {
  final DeferredLibraryLoader loadLibrary;
  final Widget Function() createWidget;

  const DeferredWidget({
    super.key,
    required this.loadLibrary,
    required this.createWidget,
  });

  @override
  State<DeferredWidget> createState() => _DeferredWidgetState();
}

class _DeferredWidgetState extends State<DeferredWidget> {
  late final Future<void> _loadFuture = widget.loadLibrary();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Failed to load page: ${snapshot.error}'));
        }
        return widget.createWidget();
      },
    );
  }
}
