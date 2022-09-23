// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserve

@Timeout(Duration(seconds: 840))

import 'dart:async';

import 'package:text_indexing/text_indexing.dart';
import 'package:test/test.dart';
// import 'data/text.dart';
// import 'data/sample_news.dart';
import 'data/sample_stocks.dart';

part 'test_index.dart';

void main() {
  group('Inverted Index', () {
    //

    // const zones = {
    //   'name': 1.0,
    //   'description': 0.5,
    //   'hashTag': 2.0,
    //   'publicationDate': 0.1
    // };

    const stockZones = {
      'name': 1.0,
      'symbol': 5.0,
      'ticker': 5.0,
      'description': 0.5,
      'hashTag': 2.0,
    };

    const searchPrase =
        'AAPL google Google GOOG tesla apple, alphabet 3m intel semiconductor';

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
      final Dictionary dictionary = {};

      // - initialize the [Postings]
      final Postings postings = {};

      // - initialize the [KGramIndex]
      final KGramIndex kGramIndex = {};

      final index = InMemoryIndex(
          dictionary: dictionary,
          postings: postings,
          kGramIndex: kGramIndex,
          zones: stockZones,
          phraseLength: 2,
          k: 3);

      // - initialize a [InMemoryIndexer] with the default analyzer
      final indexer = TextIndexer(index: index);

      final searchTerms =
          (await indexer.index.analyzer.tokenize(searchPrase)).terms;

      // get the start time in milliseconds
      final start = DateTime.now().millisecondsSinceEpoch;

      // - iterate through the sample data
      await indexer.indexCollection(sampleStocks);

      // get the end time in milliseconds
      final end = DateTime.now().millisecondsSinceEpoch;

      // calculate the time taken to index the corpus in milliseconds
      final dT = ((end - start) / 1000).toStringAsFixed(3);

      // wait for stream elements to complete printing
      await Future.delayed(const Duration(milliseconds: 250));

      // print the document term frequencies for each term in searchTerms
      await _printTermFrequencyPostings(indexer.index, searchTerms);

      // print the statistics for each term in [searchTerms].
      await _printTermStats(indexer.index, searchTerms);

      print('[InMemoryIndex] indexed ${sampleStocks.length} documents to '
          '${index.dictionary.length} postings and '
          '${index.kGramIndex.length} k-grams in $dT seconds!');

      expect(await index.vocabularyLength > 0, true);

      //
    });

    test('CachedIndex', () async {
      // - initialize a [_TestIndexRepository()]
      final repository = _TestIndexRepository();

      // initialize a CachedIndex
      final index = CachedIndex(
          cacheLimit: 100000,
          dictionaryLoader: repository.getDictionary,
          dictionaryUpdater: repository.upsertDictionary,
          dictionaryLengthLoader: () => repository.vocabularyLength,
          kGramIndexLoader: repository.getKGramIndex,
          kGramIndexUpdater: repository.upsertKGramIndex,
          postingsLoader: repository.getPostings,
          postingsUpdater: repository.upsertPostings,
          zones: stockZones,
          k: 3,
          phraseLength: 2,
          analyzer: TextAnalyzer());

      final searchTerms = (await index.analyzer.tokenize(searchPrase)).terms;

      // - initialize a [AsyncIndexer]
      final indexer = TextIndexer(index: index);

      final startTime = DateTime.now();
      // get the start time in milliseconds
      final start = startTime.millisecondsSinceEpoch;
      print('Started indexing at ${startTime.hour}:'
          '${startTime.minute.toString().padLeft(2, '0')}:'
          '${startTime.second.toString().padLeft(2, '0')}');
      print('-'.padRight(45, '-'));
      print('${'Elapsed Time'.padRight(15)}'
          '${'k-Grams'.padLeft(15)}'
          '${'Terms'.padLeft(15)}');
      print('-'.padRight(44, '-'));
      var elapsedTime = 0;
      Timer.periodic(const Duration(seconds: 5), (callback) {
        elapsedTime += 5;
        print('${elapsedTime.toString().padRight(15)}'
            '${repository.kGramIndex.length.toString().padLeft(15)}'
            '${repository.dictionary.length.toString().padLeft(15)}');
      });

      // - iterate through the sample data
      await indexer.indexCollection(sampleStocks);

      // get the end time in milliseconds
      final end = DateTime.now().millisecondsSinceEpoch;

      // calculate the time taken to index the corpus in milliseconds
      final dT = ((end - start) / 1000).toStringAsFixed(3);

      // wait for stream elements to complete printing
      await Future.delayed(const Duration(milliseconds: 250));

      // print the document term frequencies for each term in searchTerms
      await _printTermFrequencyPostings(index, searchTerms);

      // print the statistics for each term in [searchTerms].
      await _printTermStats(index, searchTerms);

      print('[CachedIndex] indexed ${sampleStocks.length} documents to '
          '${repository.dictionary.length} postings and '
          '${repository.kGramIndex.length} k-grams in $dT seconds!');

      print(' ');

      expect(await indexer.index.vocabularyLength > 0, true);
    });

    /// A test of the [AsyncIndex] on a small dataset using an index repository
    /// simulator with latency on read/write:
    /// - initialize the [_TestIndexRepository()];
    /// - initialize index as an [AsyncCallbackIndex] that calls the methods
    ///   exposed by _TestIndexRepository;
    /// - initialize a [TextIndexer];
    /// - get the sample data;
    /// - iterate through the sample data;
    /// - index each document, adding/updating terms, postings and k-grams
    ///   in the index; and
    /// - print the index statistics.
    test('AsyncCallbackIndex', () async {
      //

      // - initialize a [_TestIndexRepository()]
      final repository = _TestIndexRepository();

      final index = AsyncCallbackIndex(
          dictionaryLoader: repository.getDictionary,
          dictionaryUpdater: repository.upsertDictionary,
          dictionaryLengthLoader: () => repository.vocabularyLength,
          kGramIndexLoader: repository.getKGramIndex,
          kGramIndexUpdater: repository.upsertKGramIndex,
          postingsLoader: repository.getPostings,
          postingsUpdater: repository.upsertPostings,
          zones: stockZones,
          k: 3,
          phraseLength: 2,
          analyzer: TextAnalyzer());

      final searchTerms = (await index.analyzer.tokenize(searchPrase)).terms;

      // - initialize a [AsyncIndexer]
      final indexer = TextIndexer(index: index);

      final startTime = DateTime.now();
      // get the start time in milliseconds
      final start = startTime.millisecondsSinceEpoch;
      print('Started indexing at ${startTime.hour}:'
          '${startTime.minute.toString().padLeft(2, '0')}:'
          '${startTime.second.toString().padLeft(2, '0')}');
      print('-'.padRight(45, '-'));
      print('${'Elapsed Time'.padRight(15)}'
          '${'k-Grams'.padLeft(15)}'
          '${'Terms'.padLeft(15)}');
      print('-'.padRight(44, '-'));
      var elapsedTime = 0;
      Timer.periodic(const Duration(seconds: 5), (callback) {
        elapsedTime += 5;
        print('${elapsedTime.toString().padRight(15)}'
            '${repository.kGramIndex.length.toString().padLeft(15)}'
            '${repository.dictionary.length.toString().padLeft(15)}');
      });

      // - iterate through the sample data
      await indexer.indexCollection(sampleStocks);

      // get the end time in milliseconds
      final end = DateTime.now().millisecondsSinceEpoch;

      // calculate the time taken to index the corpus in milliseconds
      final dT = ((end - start) / 1000).toStringAsFixed(3);

      // wait for stream elements to complete printing
      await Future.delayed(const Duration(milliseconds: 250));

      // print the document term frequencies for each term in searchTerms
      await _printTermFrequencyPostings(index, searchTerms);

      // print the statistics for each term in [searchTerms].
      await _printTermStats(index, searchTerms);

      print(
          'Indexed ${sampleStocks.length} documents to ${repository.dictionary.length} '
          'postings and ${repository.kGramIndex.length} k-grams in '
          '$dT seconds!');

      print(' ');

      expect(await indexer.index.vocabularyLength > 0, true);
    });
  });
}

/// Print the document term frequencies for each term in [searchTerms].
Future<void> _printTermFrequencyPostings(
    InvertedIndex index, Iterable<String> searchTerms) async {
  /// get the document term frequency postings for the search terms
  final tfPostings = await index.getFtdPostings(searchTerms, 1);

  print('_______________________________________________________');
  print('TERM DOCUMENT FREQUENCY (search terms, minimum dFt = 1)');
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
  print('DICTIONARY STATISTICS (search terms)');
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

  // print a closing line
  print(''.padLeft(80, '-'));
}
