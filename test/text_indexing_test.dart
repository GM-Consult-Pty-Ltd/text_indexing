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
      final termsSet = <String>{};
      final docsSet = <String>{};

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
        for (final termPosting in event.entries) {
          termsSet.add(termPosting.key);
          docsSet.add(termPosting.value.entries.first.key);
        }
        print('Indexed ${termsSet.length} in ${docsSet.length} documents.');
      });

      // - iterate through the sample data
      await indexer.indexCollection(sampleNews);

      // wait for stream elements to complete printing
      await Future.delayed(const Duration(milliseconds: 250));

      // get the 5 most popular terms with their frequencies
      var terms = index.dictionary.toList(TermSortStrategy.byFrequency);
      if (terms.length > 5) {
        terms = terms.sublist(0, 5);
      }

      // print the 5 most popular terms (by document Frequency) with their frequencies
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

      /// get the term frequency in the corpus of the search terms
      final tFtIndex = await index.getTfIndex(searchTerms);

      /// print the term frequency postings for the search terms
      print('_______________________________________________________');
      print('TERM DOCUMENT FREQUENCY (search terms, minimum dFt = 2)');
      for (final e in tfPostings.entries) {
        print('Term: ${e.key}');
        for (final posting in e.value.entries) {
          print('   DocId: {${posting.key}}:    dFt: [${posting.value}]');
        }
      }
      final Map<Term, List<num>> searchTermStats = {};
      print(''.padLeft(80, '_'));
      print('DICTIONARY STATISTICS (search terms, minimum dFt = 2)');
      print(''.padLeft(80, '-'));
      print('${'Term'.padRight(10)}'
          '${'Term Frequency'.toString().padLeft(20)}'
          '${'Document Frequency'.toString().padLeft(20)}'
          '${'Inverse Document Frequency'.toString().padLeft(30)}');
      print(''.padLeft(80, '-'));
      for (final term in searchTerms) {
        final df = index.dictionary[term] ?? 0;
        final idf = iDftIndex[term] ?? 0.0;
        final tf = tFtIndex[term] ?? 0;
        print('${term.padRight(10)}'
            '${tf.toString().padLeft(20)}'
            '${df.toString().padLeft(20)}'
            '${idf.toStringAsFixed(2).padLeft(4, '0').padLeft(30)}');
      }
      expect(index.dictionary.length, termsSet.length);
      expect(sampleNews.length, docsSet.length);
    });
  });
}
