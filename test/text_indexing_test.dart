// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserve

// ignore_for_file: unused_import, unused_local_variable

@Timeout(Duration(hours: 4))

import 'dart:async';

import 'package:hive/hive.dart';
import 'package:text_indexing/text_indexing.dart';
import 'package:test/test.dart';
import 'dart:io';
// import 'data/text.dart';
import 'cached_index.dart';
import 'data/sample_news_subset.dart';
import 'data/sample_news.dart';
import 'data/sample_stocks.dart';
import 'hive_index.dart';

part 'test_index.dart';

void main() {
  group('Inverted Index', () {
    //

    const zones = {
      'name': 1.0,
      'description': 0.5,
      'hashTag': 2.0,
      'publicationDate': 0.1
    };

    const stockZones = {
      'name': 1.0,
      'symbol': 5.0,
      'ticker': 5.0,
      'description': 0.5,
      'hashTag': 2.0,
    };

    const searchPrase =
        'AAPL google GOOG tesla apple, alphabet 3m intel semiconductor';

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

      final searchTokens = (await index.analyzer.tokenize(searchPrase));

      // get the start time in milliseconds
      final start = DateTime.now().millisecondsSinceEpoch;

      _progressReporter(() => dictionary.length, () => kGramIndex.length);

      // - iterate through the sample data
      await indexer.indexCollection(sampleStocks);

      // get the end time in milliseconds
      final end = DateTime.now().millisecondsSinceEpoch;

      // calculate the time taken to index the corpus in milliseconds
      final dT = ((end - start) / 1000).toStringAsFixed(3);

      // wait for stream elements to complete printing
      await Future.delayed(const Duration(milliseconds: 250));

      // print the document term frequencies for each term in searchTerms
      await _printTermFrequencyPostings(index, searchTokens);

      // print the statistics for each term in [searchTerms].
      await _printTermStats(index, searchTokens);

      print('[InMemoryIndex] indexed ${sampleStocks.length} documents to '
          '${index.dictionary.length} postings and '
          '${index.kGramIndex.length} k-grams in $dT seconds!');

      expect(await index.vocabularyLength > 0, true);

      //
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
    test('IHiveIndex.indexCollection', () async {
      //
      final path = Directory.current.path;

      Hive.init(path);

      // - initialize the [Dictionary] and clear it
      final Box<int> dictionaryBox = await Hive.openBox('dictionary');
      await dictionaryBox.clear();

      // - initialize the [Postings] and clear it
      final Box<String> postingsBox = await Hive.openBox('postings');
      await postingsBox.clear();

      // - initialize the [KGramIndex] and clear it
      final Box<String> kGramIndexBox = await Hive.openBox('kGramIndex');
      await kGramIndexBox.clear();

      final index = HiveIndex(
          dictionaryBox: dictionaryBox,
          postingsBox: postingsBox,
          kGramIndexBox: kGramIndexBox,
          zones: stockZones,
          phraseLength: 2,
          k: 3);

      // - initialize a [InMemoryIndexer] with the default analyzer
      final indexer = TextIndexer(index: index);

      final searchTokens = (await index.analyzer.tokenize(searchPrase));

      final startTime = DateTime.now();
      // get the start time in milliseconds
      final start = startTime.millisecondsSinceEpoch;

      _progressReporter(() => dictionaryBox.length, () => kGramIndexBox.length);

      // - iterate through the sample data
      await indexer.indexCollection(sampleStocks);

      // get the end time in milliseconds
      final end = DateTime.now().millisecondsSinceEpoch;

      // calculate the time taken to index the corpus in milliseconds
      final dT = ((end - start) / 1000).toStringAsFixed(3);

      // wait for stream elements to complete printing
      await Future.delayed(const Duration(milliseconds: 250));

      // print the document term frequencies for each term in searchTerms
      await _printTermFrequencyPostings(index, searchTokens);

      // print the statistics for each term in [searchTerms].
      await _printTermStats(index, searchTokens);

      print('[InMemoryIndex] indexed ${sampleNews.length} documents to '
          '${index.dictionaryBox.length} postings and '
          '${index.kGramIndexBox.length} k-grams in $dT seconds!');

      expect(await index.vocabularyLength > 0, true);

      //
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
    test('IHiveIndex.read', () async {
      //
      final path = Directory.current.path;

      Hive.init(path);

      // - initialize the [Dictionary] and clear it
      final Box<int> dictionaryBox = await Hive.openBox('dictionary');

      // - initialize the [Postings] and clear it
      final Box<String> postingsBox = await Hive.openBox('postings');

      // - initialize the [KGramIndex] and clear it
      final Box<String> kGramIndexBox = await Hive.openBox('kGramIndex');

      final index = HiveIndex(
          dictionaryBox: dictionaryBox,
          postingsBox: postingsBox,
          kGramIndexBox: kGramIndexBox,
          zones: stockZones,
          phraseLength: 2,
          k: 3);

      final searchTokens = (await index.analyzer.tokenize(searchPrase));

      final startTime = DateTime.now();
      // get the start time in milliseconds
      final start = startTime.millisecondsSinceEpoch;

      // print the document term frequencies for each term in searchTerms
      await _printTermFrequencyPostings(index, searchTokens);

      // print the statistics for each term in [searchTerms].
      await _printTermStats(index, searchTokens);

      // get the end time in milliseconds
      final end = DateTime.now().millisecondsSinceEpoch;

      // calculate the time taken to index the corpus in milliseconds
      final dT = ((end - start) / 1000).toStringAsFixed(3);

      print('Finished all tests in $dT seconds!');

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

      final searchTokens = (await index.analyzer.tokenize(searchPrase));

      // - initialize a [AsyncIndexer]
      final indexer = TextIndexer(index: index);

      final startTime = DateTime.now();
      // get the start time in milliseconds
      final start = startTime.millisecondsSinceEpoch;

      _progressReporter(() => repository.dictionary.length,
          () => repository.kGramIndex.length);

      // - iterate through the sample data
      await indexer.indexCollection(sampleStocks);

      // get the end time in milliseconds
      final end = DateTime.now().millisecondsSinceEpoch;

      // calculate the time taken to index the corpus in milliseconds
      final dT = ((end - start) / 1000).toStringAsFixed(3);

      // wait for stream elements to complete printing
      await Future.delayed(const Duration(milliseconds: 250));

      // print the document term frequencies for each term in searchTerms
      await _printTermFrequencyPostings(index, searchTokens);

      // print the statistics for each term in [searchTerms].
      await _printTermStats(index, searchTokens);

      print('[CachedIndex] indexed ${sampleStocks.length} documents to '
          '${repository.dictionary.length} postings and '
          '${repository.kGramIndex.length} k-grams in $dT seconds!');

      print(' ');

      expect(await index.vocabularyLength > 0, true);
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
    test('AsyncCallbackIndex.indexCollection', () async {
      //

      // - initialize a [_TestIndexRepository()]
      final repository = _TestIndexRepository(latencyMs: 0);

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

      final searchTokens = (await index.analyzer.tokenize(searchPrase));

      // - initialize a [AsyncIndexer]
      final indexer = TextIndexer(index: index);

      final startTime = DateTime.now();
      // get the start time in milliseconds
      final start = startTime.millisecondsSinceEpoch;

      _progressReporter(() => repository.dictionary.length,
          () => repository.kGramIndex.length);

      // - iterate through the sample data
      await indexer.indexCollection(sampleStocks);

      // get the end time in milliseconds
      final end = DateTime.now().millisecondsSinceEpoch;

      // calculate the time taken to index the corpus in milliseconds
      final dT = ((end - start) / 1000).toStringAsFixed(3);

      // wait for stream elements to complete printing
      await Future.delayed(const Duration(milliseconds: 250));

      // print the document term frequencies for each term in searchTerms
      await _printTermFrequencyPostings(index, searchTokens);

      // print the statistics for each term in [searchTerms].
      await _printTermStats(index, searchTokens);

      print(
          'Indexed ${sampleStocks.length} documents to ${repository.dictionary.length} '
          'postings and ${repository.kGramIndex.length} k-grams in '
          '$dT seconds!');

      print(' ');

      expect(await index.vocabularyLength > 0, true);
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
    test('AsyncCallbackIndex.read', () async {
      //
      final path = Directory.current.path;

      Hive.init(path);

      // - initialize the [Dictionary] and clear it
      final Box<int> dictionaryBox = await Hive.openBox('dictionary');

      // - initialize the [Postings] and clear it
      final Box<String> postingsBox = await Hive.openBox('postings');

      // - initialize the [KGramIndex] and clear it
      final Box<String> kGramIndexBox = await Hive.openBox('kGramIndex');

      final hiveIndex = HiveIndex(
          dictionaryBox: dictionaryBox,
          postingsBox: postingsBox,
          kGramIndexBox: kGramIndexBox,
          zones: stockZones,
          phraseLength: 2,
          k: 3);

      // - initialize a [_TestIndexRepository] and populate it from the hive
      //    boxes
      final repository = _TestIndexRepository(latencyMs: 10);
      final dictionary = await hiveIndex.getDictionary();
      final terms = dictionary.terms;
      await repository.upsertDictionary(dictionary);
      await repository.upsertKGramIndex(await hiveIndex.getKGramIndex());
      await repository.upsertPostings(await hiveIndex.getPostings(terms));

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

      final searchTokens = (await index.analyzer.tokenize(searchPrase));

      final startTime = DateTime.now();
      // get the start time in milliseconds
      final start = startTime.millisecondsSinceEpoch;

      // print the document term frequencies for each term in searchTerms
      await _printTermFrequencyPostings(index, searchTokens);

      // print the statistics for each term in [searchTerms].
      await _printTermStats(index, searchTokens);

      // get the end time in milliseconds
      final end = DateTime.now().millisecondsSinceEpoch;

      // calculate the time taken to index the corpus in milliseconds
      final dT = ((end - start) / 1000).toStringAsFixed(3);

      print('Finished all tests in $dT seconds!');

      expect(await index.vocabularyLength > 0, true);

      //
    });
  });
}

void _progressReporter(int Function() termCount, int Function() kGramCount) {
  final startTime = DateTime.now();
  final start = startTime.millisecondsSinceEpoch;
  print('Started indexing at ${startTime.hour}:'
      '${startTime.minute.toString().padLeft(2, '0')}:'
      '${startTime.second.toString().padLeft(2, '0')}');
  print('-'.padRight(48, '-'));
  print('${'Elapsed Time'.padRight(15)}'
      '${'k-Grams'.padLeft(15)}'
      '${'Terms'.padLeft(15)}');
  print('-'.padRight(48, '-'));
  var elapsedTime = 0;
  Timer.periodic(const Duration(seconds: 5), (callback) {
    elapsedTime += 5;
    print('${elapsedTime.toString().padRight(15)}'
        '${kGramCount().toString().padLeft(15)}'
        '${termCount().toString().padLeft(15)}');
  });
}

/// Print the document term frequencies for each term in [searchTerms].
Future<void> _printTermFrequencyPostings(
    InvertedIndex index, Iterable<Token> tokens) async {
  /// get the document term frequency postings for the search terms
  ///
  final searchTerms = tokens.terms;
  final searchKgrams = tokens.kGrams(3);
  final startTime = DateTime.now();
  final start = startTime.millisecondsSinceEpoch;

  final tfPostings = await index.getFtdPostings(searchTerms, 1);

  // get the end time in milliseconds
  final end = DateTime.now().millisecondsSinceEpoch;

  // calculate the time taken to index the corpus in milliseconds
  final dT = ((end - start) / 1000).toStringAsFixed(3);

  print('_______________________________________________________');
  print('TERM DOCUMENT FREQUENCY (search terms, minimum dFt = 1)');
  for (final e in tfPostings.entries) {
    print('Term: ${e.key}');
    for (final posting in e.value.entries) {
      print('   DocId: {${posting.key}}:    dFt: [${posting.value}]');
    }
  }
  print('_______________________________________________________');
  print('Retrieved ${tfPostings.length} Ftd postings for ${searchTerms.length} '
      'terms in $dT seconds.');
}

/// Print the statistics for each term in [searchTerms].
Future<void> _printTermStats(
    InvertedIndex index, Iterable<Token> tokens) async {
  //

  final searchTerms = tokens.terms;

  final searchKgrams = tokens.kGrams(3);

  final startTime = DateTime.now();
  final start = startTime.millisecondsSinceEpoch;

  // get the inverse term frequency index for the searchTerms
  final iDftIndex = await index.getIdFtIndex(searchTerms);

  // get the term frequency in the corpus of the searchTerms
  final tFtIndex = await index.getTfIndex(searchTerms);

  // get the dictionary for searchTerms
  final dictionary = await index.getDictionary(searchTerms);

  final kGramMap = await index.getKGramIndex(searchKgrams.keys);

  final kGramTerms = <String>{};
  for (final terms in kGramMap.values) {
    kGramTerms.addAll(terms);
  }

  final kGramPostings = await index.getPostings(kGramTerms);

  // get the end time in milliseconds
  final end = DateTime.now().millisecondsSinceEpoch;

  // calculate the time taken to index the corpus in milliseconds
  final dT = ((end - start)).toStringAsFixed(3);

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
  print(''.padLeft(80, '-'));

  // print a closing line
  print(''.padLeft(80, '-'));
  print('Retrieved');
  print('- dictionary for ${dictionary.length} terms;');
  print('- term frequencies for ${tFtIndex.length} terms;');
  print('- inverse document frequencies for ${iDftIndex.length} terms; and');
  print('- k-gram postings for ${kGramTerms.length} terms.');
  print('in $dT milliseconds.');
  print(''.padLeft(80, '-'));
  print(''.padLeft(80, '-'));
}
