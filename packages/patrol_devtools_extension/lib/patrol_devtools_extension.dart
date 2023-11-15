import 'dart:async';

import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';
import 'package:patrol_devtools_extension/api/patrol_service_extension_api.dart';
import 'package:patrol_devtools_extension/native_inspector/native_inspector.dart';
import 'package:patrol_devtools_extension/native_inspector/node.dart';

class PatrolDevToolsExtension extends StatefulWidget {
  const PatrolDevToolsExtension({super.key});

  @override
  State<PatrolDevToolsExtension> createState() {
    return _PatrolDevToolsExtensionState();
  }
}

class _PatrolDevToolsExtensionState extends State<PatrolDevToolsExtension> {
  final runner = _Runner();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: runner,
      builder: (context, state, child) {
        return NativeInspector(
          roots: state.roots,
          currentNode: state.currentNode,
          onNodeChanged: runner.changeNode,
          onRefreshPressed: runner.getNativeUITree,
        );
      },
    );
  }
}

class _Runner extends ValueNotifier<_State> {
  _Runner() : super(_State());

  bool get isAndroidApp {
    return serviceManager.connectedApp?.operatingSystem == 'android';
  }

  void changeNode(Node? node) {
    value.currentNode = node;
    notifyListeners();
  }

  Future<void> getNativeUITree() async {
    value
      ..roots = []
      ..currentNode = null;

    final api = PatrolServiceExtensionApi(
      service: serviceManager.service!,
      isolate: serviceManager.isolateManager.mainIsolate,
    );

    final result = await api.getNativeUITree();

    switch (result) {
      case ApiSuccess(:final data):
        value.roots = data.roots
            .map((e) => Node(e, null, androidNode: isAndroidApp))
            .toList();
      case ApiFailure<void> _:
      // TODO: Handle failure
    }

    notifyListeners();
  }
}

class _State {
  List<Node> roots = [];
  Node? currentNode;
}
