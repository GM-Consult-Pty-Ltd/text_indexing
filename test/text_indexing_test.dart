// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

// ignore_for_file: unused_local_variable

import 'package:text_indexing/text_indexing.dart';
import 'package:test/test.dart';
import 'data/text.dart';
import 'data/sample_news.dart';

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

// initialize a Set for the vocabulary state
      final termsSet = <String>{};

      // initialize a Set for the document ids state
      final docsSet = <String>{};

      // - initialize the [Dictionary]
      final dictionary = <String, int>{};

      // - initialize the [Postings]
      final postings = <String, Map<String, Map<String, List<int>>>>{};

      // - initialize a [InMemoryIndexer]
      final indexer = TextIndexer.inMemory(
          dictionary: dictionary, postings: postings, analyzer: TextAnalyzer());

      final searchTerms = (await indexer.index.analyzer
              .tokenize('stock market tesla EV battery'))
          .tokens
          .terms;

      // indexer.postingsStream.listen((event) {
      //   if (event.isNotEmpty) {
      //     final PostingsEntry posting = event.entries.first;
      //     if (posting.value.isNotEmpty) {
      //       final DocumentPostingsEntry docPostings =
      //           posting.value.entries.first;
      //       final docId = docPostings.docId;
      //       final terms = event.terms;
      //       print('$docId: $terms');
      //     }
      //   }
      //   for (final termPosting in event.entries) {
      //     termsSet.add(termPosting.key);
      //     docsSet.add(termPosting.value.entries.first.key);
      //   }
      //   print(
      //       'Indexed ${termsSet.length} terms from ${docsSet.length} documents.');
      // });

      // - iterate through the sample data
      await Future.forEach(textData.entries,
          (MapEntry<String, String> doc) async {
        // - index each document
        await indexer.indexText(doc.key, doc.value);
      });

      // wait for stream elements to complete printing
      await Future.delayed(const Duration(milliseconds: 250));

      // print the document term frequencies for each term in searchTerms
      await _printTermFrequencyPostings(indexer.index, searchTerms);

      // print the statistics for each term in [searchTerms].
      await _printTermStats(indexer.index, searchTerms);

      expect(await indexer.index.vocabularyLength, termsSet.length);
      expect(textData.length, docsSet.length);

      //
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

      // - iterate through the sample data
      await indexer.indexCollection(sampleNews);

      // wait for stream elements to complete printing
      await Future.delayed(const Duration(milliseconds: 250));

      // print the document term frequencies for each term in searchTerms
      await _printTermFrequencyPostings(index, searchTerms);

      // print the statistics for each term in [searchTerms].
      await _printTermStats(index, searchTerms);
    });
  });
}

/// Print the document term frequencies for each term in [searchTerms].
Future<void> _printTermFrequencyPostings(
    InvertedIndex index, Iterable<String> searchTerms) async {
  /// get the document term frequency postings for the search terms
  final tfPostings = await index.getFtdPostings(searchTerms, 2);

  print('_______________________________________________________');
  print('TERM DOCUMENT FREQUENCY (search terms, minimum dFt = 2)');
  for (final e in tfPostings.entries) {
    print('Term: ${e.key}');
    for (final posting in e.value.entries) {
      print('   DocId: {${posting.key}}:    dFt: [${posting.value}]');
    }
  }
}

/// Print the statistics for each term in [searchTerms].
Future<void> _printTermStats(
    InvertedIndex index, Iterable<String> searchTerms) async {
  //

  // get the inverse term frequency index for the searchTerms
  final iDftIndex = await index.getIdFtIndex(searchTerms);

  // get the term frequency in the corpus of the searchTerms
  final tFtIndex = await index.getTfIndex(searchTerms);

  // get the dictionary for searchTerms
  final dictionary = await index.getDictionary(searchTerms);

  // print the headings
  print(''.padLeft(80, '_'));
  print('DICTIONARY STATISTICS (search terms, minimum dFt = 2)');
  print(''.padLeft(80, '-'));
  print('${'Term'.padRight(10)}'
      '${'Term Frequency'.toString().padLeft(20)}'
      '${'Document Frequency'.toString().padLeft(20)}'
      '${'Inverse Document Frequency'.toString().padLeft(30)}');
  print(''.padLeft(80, '-'));

  // print the statistics
  for (final term in searchTerms) {
    final df = dictionary[term] ?? 0;
    final idf = iDftIndex[term] ?? 0.0;
    final tf = tFtIndex[term] ?? 0;
    print('${term.padRight(10)}'
        '${tf.toString().padLeft(20)}'
        '${df.toString().padLeft(20)}'
        '${idf.toStringAsFixed(2).padLeft(4, '0').padLeft(30)}');
  }
}
