// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

// ignore: unused_import
import 'package:text_analysis/text_analysis.dart';
import 'package:text_indexing/text_indexing.dart';
import 'package:test/test.dart';
import 'data/text.dart';

void main() {
  group('A group of tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () async {
      final indexer = InMemoryIndexer();
      final documents = textData;
      for (final doc in documents.entries) {
        await indexer.index(doc.key, doc.value);
      }
      print(indexer.dictionary.terms);
    });
  });
}
