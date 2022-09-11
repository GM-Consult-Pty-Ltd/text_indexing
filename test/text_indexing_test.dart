// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/text_indexing.dart';
import 'package:test/test.dart';
import 'data/text.dart';

void main() {
  group('Inverted Index', () {
    //

    setUp(() {
      // Additional setup goes here.
    });

    /// A simple test of the [InMemoryIndexer] on a small dataset:
    /// - initialize the [TermDictionary];
    /// - initialize the [PostingsMap];
    /// - initialize a [InMemoryIndexer];
    /// - listen to the [InMemoryIndexer.postingsStream], printing the
    ///   emitted postings for each indexed document;
    /// - get the sample data;
    /// - iterate through the sample data;
    /// - index each document, adding/updating terms in the [TermDictionary]
    ///   and postings in the [PostingsMap] ; and
    /// - print the top 5 most popular [TermDictionary.terms].
    test('InMemoryIndexer.index', () async {
      //

      // - initialize the [TermDictionary]
      final dictionary = <String, int>{};

      // - initialize the [PostingsMap]
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
  });
}
