// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserve

// ignore_for_file: unused_import, unused_local_variable

@Timeout(Duration(hours: 4))

import 'dart:async';
import 'package:gmconsult_dev/gmconsult_dev.dart';
import 'package:gmconsult_dev/test_data.dart';
import 'package:text_indexing/src/_index.dart';
import 'package:test/test.dart';
import 'dart:io';
import 'data/sample_news_subset.dart';
import 'data/sample_news.dart';
import 'data/sample_stocks.dart';
import 'data/vocabulary.dart';

void main() {
  group('Inverted Index', () {
    //

    setUp(() {
      // Additional setup goes here.
    });

    const zones = {
      'name': 1.0,
      'description': 0.5,
      'hashTag': 2.0,
      'publicationDate': 0.1
    };

    const stockZones = {
      'name': 1.0,
      'description': 0.5,
      'symbol': 5.0,
      'hashTag': 2.0,
    };

    const searchPrase = 'AAPL google 5G modem 3m, intel, semiconductor';

    test('Index on sampleNews', () async {
      final data = TestData.stockNews;

      final phrase = '5g modem chip';

      final index = await _getIndex(data,
          //
          {'name': 1.0, 'description': 1.0}
          //
          );

      final searchTokens = (await index.tokenizer.tokenize(phrase,
          nGramRange: NGramRange(1, 3), strategy: TokenizingStrategy.keyWords));

      final terms = searchTokens.terms;

      for (final key in index.keywordPostings.keys) {
        print('Keyword: $key');
      }

      for (final key in index.dictionary.keys) {
        print('Term: $key');
      }

      final kGrams = terms.toKGramsMap().keys;

      final dftSearch = await index.getDictionary(terms);

      final postingsSearch = await index.getPostings(terms);

      final keyWordsSearch = await index.getKeywordPostings(terms);

      final kGramsSearch = await index.getKGramIndex(kGrams);

      final searchResults = phrase.getSuggestions(kGramsSearch.terms);

      _printKeywords(index: keyWordsSearch, data: data, limit: 25);

      // print the document term frequencies for each term in searchTerms
      // await _printTermFrequencyPostings(index, searchTokens);

      // print the statistics for each term in [searchTerms].
      // await _printTermStats(index, searchTokens);

      // await saveKgramIndex(kGramIndex);
    });

    /// A simple test of the [InMemoryIndexer] on a small dataset:
    /// - initialize the [DftMap];
    /// - initialize the [PostingsMap];
    /// - initialize a [InMemoryIndexer];
    /// - listen to the [InMemoryIndexer.postingsStream], printing the
    ///   emitted postings for each indexed document;
    /// - get the sample data;
    /// - iterate through the sample data;
    /// - index each document, adding/updating terms in the [DftMap]
    ///   and postings in the [PostingsMap] ; and
    /// - print the top 5 most popular [DftMap.terms].
    test('InMemoryIndexer.index', () async {
      //
      final collection = sampleStocks;

      // - initialize the [DftMap]
      final DftMap dictionary = {};

      // - initialize the [PostingsMap]
      final PostingsMap postings = {};

      // - initialize the [KGramsMap]
      final KGramsMap kGramIndex = {};

      final index = InMemoryIndex(
          tokenizer: TextTokenizer.english,
          collectionSize: collection.length,
          keywordExtractor: English.analyzer.keywordExtractor,
          dictionary: dictionary,
          strategy: TokenizingStrategy.all,
          postings: postings,
          kGramIndex: kGramIndex,
          zones: stockZones,
          nGramRange: NGramRange(1, 2),
          k: 3);

      // - initialize a [InMemoryIndexer] with the default tokenizer
      final indexer = TextIndexer(index);

      final searchTokens = (await index.tokenizer.tokenize(searchPrase));

      // get the start time in milliseconds
      final start = DateTime.now().millisecondsSinceEpoch;

      _progressReporter(() => dictionary.length, () => kGramIndex.length);

      // - iterate through the sample data
      await indexer.indexCollection(collection);

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

      _printKGrams(index: index.kGramIndex);

      print('[InMemoryIndex] indexed ${sampleStocks.length} documents to '
          '${index.dictionary.length} postings and '
          '${index.kGramIndex.length} k-grams in $dT seconds!');

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
  var termCountState = 0;
  Timer.periodic(const Duration(seconds: 5), (timer) {
    if (termCount() > termCountState) {
      elapsedTime += 5;
      print('${elapsedTime.toString().padRight(15)}'
          '${kGramCount().toString().padLeft(15)}'
          '${termCount().toString().padLeft(15)}');
    } else {
      timer.cancel();
    }
    termCountState = termCount();
  });
}

void _printKGrams({required KGramsMap index, int limit = 25}) {
  print('K-GRAMS');
  final entries = index.length > limit
      ? index.entries.toList().sublist(0, limit)
      : index.entries.toList();

  for (final e in entries) {
    print('${e.key}: ${e.value.toString()}');
  }
}

void _printKeywords(
    {required KeywordPostingsMap index,
    required Map<String, Map<String, dynamic>> data,
    int limit = 25}) {
  print('KEYWORDS');
  final entries = index.entries.toList();
  entries.sort(((a, b) => b.value.length.compareTo(a.value.length)));
  // entries = entries.length > limit
  //     ? entries.toList().sublist(0, limit)
  //     : entries.toList();

  for (final e in entries) {
    var value = e.value.entries.toList();
    value.sort(((a, b) => b.value.compareTo(a.value)));
    value = value.length > 3 ? value.sublist(0, 3) : value;
    print('${e.key}: ${value.length.toString()} hits');
    var i = 0;
    for (final hit in value) {
      i++;
      final doc = data[hit.key];
      if (doc != null) {
        final title = doc['name'].toString();
        final score = hit.value;
        print('  $i. $title (${score.toStringAsFixed(1)})');
      }
    }
  }
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

  final results = <Map<String, dynamic>>[];

  for (final e in tfPostings.entries) {
    for (final posting in e.value.entries) {
      results.add({'Term': e.key, 'DocId': posting.key, ' dFt': posting.value});
    }
  }

  Console.out(
      title: 'TERM DOCUMENT FREQUENCY', results: results, minPrintWidth: 120);

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

  final kGramTerms = kGramMap.terms;

  final kGramPostings = await index.getPostings(kGramTerms);

  // get the end time in milliseconds
  final end = DateTime.now().millisecondsSinceEpoch;

  // calculate the time taken to index the corpus in milliseconds
  final dT = ((end - start)).toStringAsFixed(3);

  final results = <Map<String, dynamic>>[];
  for (final term in searchTerms) {
    final df = dictionary[term] ?? 0;
    final idf = iDftIndex[term] ?? 0.0;
    final tf = tFtIndex[term] ?? 0;

    results.add({
      'Term': term,
      'Term Frequency': tf,
      'Document Frequency': df,
      'Inverse Document Frequency': idf
    });
  }

  Console.out(
      title: 'DICTIONARY STATISTICS', results: results, minPrintWidth: 120);

  final stats = <Map<String, dynamic>>[];
  stats.add({
    'Search Terms': dictionary.length,
    'k-Gram Terms': kGramTerms.length,
    'Elapsed Time': dT
  });

  Console.out(title: 'READ PERFORMANCE', results: stats, minPrintWidth: 120);
}

Future<void> saveKgramIndex(KGramsMap value,
    [String fileName = 'kGramIndex']) async {
  final buffer = StringBuffer();
  buffer.writeln('const kGrams = {');
  for (final entry in value.entries) {
    buffer.write('r"${entry.key}": {');
    var i = 0;
    for (final term in entry.value) {
      buffer.write(i > 0 ? ', ' : '');
      buffer.write('r"$term"');
      i++;
    }
    buffer.writeln('},');
  }
  buffer.writeln('};');
  final out = File(r'test\data\kGramIndex.txt').openWrite();
  out.writeln(buffer.toString());
  await out.close();
}

Future<InMemoryIndex> _getIndex(JsonCollection documents,
    [Map<String, double> zones = const {
      'name': 1,
      'descriptions': 0.5
    }]) async {
  final index = InMemoryIndex(
      tokenizer: TextTokenizer.english,
      collectionSize: documents.length,
      strategy: TokenizingStrategy.all,
      // nGramRange: NGramRange(1, 3),
      keywordExtractor: English.analyzer.keywordExtractor,
      zones: zones);
  final indexer = TextIndexer(index);
  await indexer.indexCollection(documents);
  // await saveKgramIndex(index.kGramIndex);
  return index;
}
