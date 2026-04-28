import 'package:xml/xml.dart';

extension XmlElementTextX on XmlElement {
  String? getElementText(String name) {
    return getElement(name)?.innerText.trim();
  }
}

extension NullableIntX on int {
  T let<T>(T Function(int value) transform) => transform(this);
}

extension XmlElementIterableX on Iterable<XmlElement> {
  XmlElement? get firstOrNull => isEmpty ? null : first;
}

