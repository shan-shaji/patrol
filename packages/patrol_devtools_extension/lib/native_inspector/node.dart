import 'package:patrol_devtools_extension/api/contracts.dart';

class Node {
  Node(this.nativeView, this.parent, {required this.androidNode}) {
    children = nativeView.children
        .map((e) => Node(e, this, androidNode: androidNode))
        .toList();

    fullNodeName = _nodeName(nativeView.className, nativeView.resourceName);

    shortNodeName = _shortNodeName(
      nativeView.className,
      nativeView.resourceName,
    );

    initialCharacter =
        shortNodeName.isNotEmpty ? shortNodeName[0].toUpperCase() : '';
  }

  final NativeView nativeView;
  final Node? parent;
  final bool androidNode;

  late final List<Node> children;
  late final String fullNodeName;
  late final String shortNodeName;
  late final String initialCharacter;

  static List<String> ignoreTypePrefixes = ['android.widget.', 'android.view.'];

  String _shortNodeName(String? type, String? resourceName) {
    var typeName = type ?? '';

    if (androidNode && typeName.isNotEmpty) {
      for (final prefix in ignoreTypePrefixes) {
        if (typeName.startsWith(prefix)) {
          typeName = typeName.substring(prefix.length);
          break;
        }
      }
    }

    return _nodeName(typeName, resourceName);
  }

  String _nodeName(String? type, String? resourceName) {
    if (resourceName == null || resourceName.isEmpty) {
      return '$type';
    }
    return "$type-[<'$resourceName'>]";
  }
}
