import 'package:flutter_test/flutter_test.dart';
import 'package:gitangali/src/data/book_repository.dart';
import 'package:gitangali/src/data/legacy_asset_resolver.dart';
import 'package:xml/xml.dart';

void main() {
  group('BookRepository.parseBookDocument', () {
    late BookRepository repository;
    late LegacyAssetResolver resolver;

    setUp(() {
      repository = BookRepository();
      resolver = LegacyAssetResolver(const [
        'assets/legacy/Images/bg.png',
        'assets/legacy/Images/btn.png',
        'assets/legacy/Images/Anim/bg0001.png',
        'assets/legacy/Images/Anim/bg0002.png',
        'assets/legacy/Sounds/song.m4a',
      ]);
    });

    test('parses minimum supported book nodes into pages', () {
      final document = XmlDocument.parse(_validXml);
      final book = repository.parseBookDocument(document, resolver);

      expect(book.id, 'book-id');
      expect(book.title, 'Book title');
      expect(book.pages, isNotEmpty);
      expect(book.pages.first.contentTitle, 'Intro content');
      expect(book.pages.first.paragraphs.first.text, 'Hello world');
      expect(book.pages.first.backgroundAsset, 'assets/legacy/Images/bg.png');
      expect(book.pages.first.backgroundFrames, isEmpty);
      expect(book.pages.first.audio?.assetPath, 'assets/legacy/Sounds/song.m4a');
      expect(book.pages.first.controls.first.targetPageIndex, 1);
    });

    test('parses keyframe backgrounds into frame list', () {
      final document = XmlDocument.parse(_xmlWithKeyframeBackground);
      final book = repository.parseBookDocument(document, resolver);

      expect(book.pages.first.backgroundAsset, 'assets/legacy/Images/Anim/bg0001.png');
      expect(book.pages.first.backgroundFrames, [
        'assets/legacy/Images/Anim/bg0001.png',
        'assets/legacy/Images/Anim/bg0002.png',
      ]);
    });

    test('throws for unsupported root version', () {
      final document = XmlDocument.parse(
        _validXml.replaceFirst('version="1.0"', 'version="2.0"'),
      );

      expect(
        () => repository.parseBookDocument(document, resolver),
        throwsA(isA<StateError>()),
      );
    });

    test('throws when head or body is missing', () {
      const missingBody = '<book version="1.0"><head><id>x</id></head></book>';
      final document = XmlDocument.parse(missingBody);

      expect(
        () => repository.parseBookDocument(document, resolver),
        throwsA(isA<StateError>()),
      );
    });

    test('throws when root section is missing', () {
      const missingSection = '''
<book version="1.0">
  <head><id>x</id></head>
  <body></body>
</book>
''';
      final document = XmlDocument.parse(missingSection);

      expect(
        () => repository.parseBookDocument(document, resolver),
        throwsA(isA<StateError>()),
      );
    });
  });
}

const _validXml = '''
<book version="1.0">
  <head>
    <id>book-id</id>
    <book-title>Book title</book-title>
  </head>
  <body>
    <style name="base" font-name="MurariChandUni" font-size="18" text-color="#111111" text-alignment="center" />
    <section>
      <title><p>Intro title</p></title>
      <content-title><p>Intro content</p></content-title>
      <page>
        <p style="base">Hello world</p>
        <comments><p>Comment text</p></comments>
        <show-number>1</show-number>
        <controls>
          <control type="page-link">
            <arg>2</arg>
            <image>btn.png</image>
          </control>
        </controls>
        <audio autoplay="1">song.m4a</audio>
        <background image="bg.png" />
      </page>
    </section>
  </body>
</book>
''';

const _xmlWithKeyframeBackground = '''
<book version="1.0">
  <head>
    <id>book-id</id>
    <book-title>Book title</book-title>
  </head>
  <body>
    <section>
      <page>
        <p>Hello world</p>
        <background>
          <target type="keyframe">Anim</target>
        </background>
      </page>
    </section>
  </body>
</book>
''';
