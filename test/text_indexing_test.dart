// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/text_indexing.dart';
import 'package:test/test.dart';
import 'data/text.dart';

part 'test_index.dart';

void main() {
  group('Inverted Index', () {
    //

    setUp(() {
      // Additional setup goes here.
    });

    /// A simple test of the [InMemoryIndexer] on a small dataset:
    /// - initialize the [Dictionary];
    /// - initialize the [Postings];
    /// - initialize a [InMemoryIndexer];
    /// - listen to the [InMemoryIndexer.postingsStream], printing the
    ///   emitted postings for each indexed document;
    /// - get the sample data;
    /// - iterate through the sample data;
    /// - index each document, adding/updating terms in the [Dictionary]
    ///   and postings in the [Postings] ; and
    /// - print the top 5 most popular [Dictionary.terms].
    test('InMemoryIndexer.index', () async {
      //

      // - initialize the [Dictionary]
      final dictionary = <String, int>{};

      // - initialize the [Postings]
      final postings = <String, Map<String, List<int>>>{};

      // - initialize a [InMemoryIndexer]
      final indexer =
          InMemoryIndexer(dictionary: dictionary, postings: postings);

      indexer.postingsStream.listen((event) {
        if (event.isNotEmpty) {
          final docId = event.first.docId;
          final terms = event.map((e) => e.term).toList();
          print('$docId: $terms');
        }
      });

      // - get the sample data
      final documents = textData;

      // - iterate through the sample data
      await Future.forEach(documents.entries,
          (MapEntry<String, String> doc) async {
        // - index each document
        await indexer.index(doc.key, doc.value);
      });

      // wait for stream elements to complete printing
      await Future.delayed(const Duration(milliseconds: 250));

      // print the 5 most popuplar terms with their frequencies
      var terms = dictionary.toList(TermSortStrategy.byFrequency);
      if (terms.length > 5) {
        terms = terms.sublist(0, 5);
      }
      for (final term in terms) {
        print('${term.term}: ${term.frequency}');
      }
    });

    /// A simple test of the [PersistedIndexer] on a small dataset using a
    /// simulated persisted index repository with 50 millisecond latency on
    /// read/write operations to the [Dictionary] and [Postings]:
    /// - initialize the [_TestIndex()];
    /// - initialize a [PersistedIndexer];
    /// - listen to the [PersistedIndexer.postingsStream], printing the
    ///   emitted postings for each indexed document;
    /// - get the sample data;
    /// - iterate through the sample data;
    /// - index each document, adding/updating terms in the [_TestIndex.dictionary]
    ///   and postings in the [_TestIndex.postings] ; and
    /// - print the top 5 most popular [_TestIndex.dictionary.terms].
    test('PersistedIndexer.index', () async {
      //

      // - initialize a [_TestIndex()]
      final index = _TestIndex();

      // - initialize a [InMemoryIndexer]
      final indexer = PersistedIndexer(
          termsLoader: index.loadTerms,
          dictionaryUpdater: index.updateDictionary,
          postingsLoader: index.loadTermPostings,
          postingsUpdater: index.upsertTermPostings);

      indexer.postingsStream.listen((event) {
        if (event.isNotEmpty) {
          final docId = event.first.docId;
          final terms = event.map((e) => e.term).toList();
          print('$docId: $terms');
        }
      });

      // - get the sample data
      final documents = textData;

      // - iterate through the sample data
      await Future.forEach(documents.entries,
          (MapEntry<String, String> doc) async {
        // - index each document
        await indexer.index(doc.key, doc.value);
      });

      // wait for stream elements to complete printing
      await Future.delayed(const Duration(milliseconds: 250));

      // print the 5 most popuplar terms with their frequencies
      var terms = index.dictionary.toList(TermSortStrategy.byFrequency);
      if (terms.length > 5) {
        terms = terms.sublist(0, 5);
      }
      for (final term in terms) {
        print('${term.term}: ${term.frequency}');
      }
    });
  });
}
