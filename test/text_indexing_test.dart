// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

// ignore_for_file: unused_local_variable

import 'package:text_indexing/text_indexing.dart';
import 'package:test/test.dart';
import 'data/text.dart';
import 'data/sample_news_subset.dart';

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
      final postings = <String, Map<String, Map<String, List<int>>>>{};

      // - initialize a [InMemoryIndexer]
      final indexer = TextIndexer.inMemory(
          dictionary: dictionary, postings: postings, analyzer: TextAnalyzer());

      indexer.postingsStream.listen((event) {
        if (event.isNotEmpty) {
          final PostingsEntry posting = event.entries.first;
          if (posting.value.isNotEmpty) {
            final DocumentPostingsEntry docPostings =
                posting.value.entries.first;
            final docId = docPostings.docId;
            final terms = event.terms;
            print('$docId: $terms');
          }
        }
      });

      // - get the sample data
      final documents = textData;

      // - iterate through the sample data
      await Future.forEach(documents.entries,
          (MapEntry<String, String> doc) async {
        // - index each document
        await indexer.indexText(doc.key, doc.value);
      });

      // wait for stream elements to complete printing
      await Future.delayed(const Duration(milliseconds: 250));

      // print the 5 most popuplar terms with their frequencies
      var terms = dictionary.toList(TermSortStrategy.byFrequency);
      if (terms.length > 5) {
        terms = terms.sublist(0, 5);
      }
      for (final term in terms) {
        print('${term.term}: ${term.dFt}');
      }
    });

    /// A simple test of the [AsyncIndexer] on a small dataset using a
    /// simulated persisted index repository with 50 millisecond latency on
    /// read/write operations to the [Dictionary] and [Postings]:
    /// - initialize the [_TestIndex()];
    /// - initialize a [AsyncIndexer];
    /// - listen to the [AsyncIndexer.postingsStream], printing the
    ///   emitted postings for each indexed document;
    /// - get the sample data;
    /// - iterate through the sample data;
    /// - index each document, adding/updating terms in the [_TestIndex.dictionary]
    ///   and postings in the [_TestIndex.postings] ; and
    /// - print the top 5 most popular [_TestIndex.dictionary.terms].
    test('AsyncIndexer.index', () async {
      //

      // - initialize a [_TestIndex()]
      final index = _TestIndex();

      final searchTerms =
          (await index.analyzer.tokenize('stock market tesla EV battery'))
              .tokens
              .terms;

      // - initialize a [AsyncIndexer]
      final indexer = TextIndexer.index(index: index);

      // listen to the indexer.postingsStream and print the postings count for each term.
      indexer.postingsStream.listen((event) {
        if (event.isNotEmpty) {
          final docPostings = event.values.first;
          if (docPostings.isNotEmpty) {
            print(
                'Postings received for document  {${docPostings.entries.first.key}}');
          }
        }
      });

      // - define the FieldNames to be indexed
      final fields = ['name', 'description', 'hashTags', 'publicationDate'];

      // - iterate through the sample data
      await indexer.indexCollection(sampleNewsSubset, fields);

      // wait for stream elements to complete printing
      await Future.delayed(const Duration(milliseconds: 250));

      // get the 5 most popular terms with their frequencies
      var terms = index.dictionary.toList(TermSortStrategy.byFrequency);
      if (terms.length > 5) {
        terms = terms.sublist(0, 5);
      }

      // print the 5 most popular terms with their frequencies
      print('_______________________________________________________');
      print('DOCUMENT FREQUENCY (top 5 terms)');
      for (final term in terms) {
        print('Term: "${term.term}":   dFt: ${term.dFt}');
      }

      /// get the inverse term frequency index for the search terms
      final iDftIndex = await index.getIdFtIndex(searchTerms);

      // get the inverse document frequency index.
      var idftIndex = iDftIndex.toList(TermSortStrategy.byFrequency);
      if (idftIndex.length > 5) {
        idftIndex = idftIndex.sublist(0, 5);
      }
      // print the 5 terms with the highest inverse document frequency.
      print('_______________________________________________________');
      print('INVERSE DOCUMENT FREQUENCY (search terms)');
      for (final term in idftIndex) {
        print('Term: "${term.term}":    iDFt ${term.iDFt.toStringAsFixed(2)}');
      }

      /// get the document term frequency postings for the search terms
      final tfPostings = await index.getFtdPostings(searchTerms, 2);

      /// print the term frequency postings for the search terms
      print('_______________________________________________________');
      print('TERM DOCUMENT FREQUENCY (search terms, minimum dFt = 2)');
      for (final e in tfPostings.entries) {
        print('Term: ${e.key}');
        for (final posting in e.value.entries) {
          print('   DocId: {${posting.key}}:    dFt: [${posting.value}]');
        }
      }
    });
  });
}
