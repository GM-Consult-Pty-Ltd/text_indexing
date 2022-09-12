// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

// ignore: unused_import
import 'package:text_indexing/text_indexing.dart';

/// Two examples using the indexers in this package are provided:
/// - [_inMemoryIndexerExample] is a simple example of a [InMemoryIndexer]
///   indexing the [textData] dataset; and
/// - [_persistedIndexerExample] is a simple example of a [PersistedIndexer]
///   indexing the [textData] dataset.
void main() async {
  //

  // Run a simple example of the [InMemoryIndexer] on the [textData] dataset.
  await _inMemoryIndexerExample(textData);

  //  Run a simple example of the [PersistedIndexer] on the [textData] dataset.
  await _persistedIndexerExample(textData);

  //
}

/// A simple example of the [InMemoryIndexer] on the [documents] dataset:
/// - initialize the [Dictionary];
/// - initialize the [Postings];
/// - initialize a [InMemoryIndexer];
/// - listen to the [InMemoryIndexer.postingsStream], printing the
///   emitted postings for each indexed document;
/// - iterate through the sample data;
/// - index each document, adding/updating terms in the [Dictionary]
///   and postings in the [Postings] ; and
/// - print the top 5 most popular [Dictionary.terms].
Future<void> _inMemoryIndexerExample(Map<String, String> documents) async {
  //

  // - initialize the [Dictionary]
  final dictionary = <String, int>{};

  // - initialize the [Postings]
  final postings = <String, Map<String, List<int>>>{};

  // - initialize a [InMemoryIndexer]
  final indexer = InMemoryIndexer(dictionary: dictionary, postings: postings);

  indexer.postingsStream.listen((event) {
    if (event.isNotEmpty) {
      final docId = event.first.docId;
      final terms = event.map((e) => e.term).toList();
      print('$docId: $terms');
    }
  });

  // - iterate through the sample data
  await Future.forEach(documents.entries, (MapEntry<String, String> doc) async {
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
}

/// A simple test of the [PersistedIndexer] on a small dataset using a
/// simulated persisted index repository with 50 millisecond latency on
/// read/write operations to [Dictionary] and [Postings] hashmaps:
/// - initialize the [_TestIndex()];
/// - initialize a [PersistedIndexer];
/// - listen to the [PersistedIndexer.postingsStream], printing the
///   emitted postings for each indexed document;
/// - iterate through the sample data;
/// - index each document, adding/updating terms in the [_TestIndex.dictionary]
///   and postings in the [_TestIndex.postings] ; and
/// - print the top 5 most popular [_TestIndex.dictionary.terms].
Future<void> _persistedIndexerExample(Map<String, String> documents) async {
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

  // - iterate through the sample data
  await Future.forEach(documents.entries, (MapEntry<String, String> doc) async {
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
}

/// Four paragraphs of text used for testing.
///
/// Includes numbers, currencies, abbreviations, hyphens and identifiers
final textData = {
  'doc000': 'The Dow Jones rallied even as U.S. troops were put on alert amid '
      'the Ukraine crisis. Tesla stock fought back while Apple '
      'stock struggled. ',
  'doc001': '[TSLA.XNGS] Tesla\'s #TeslaMotor Stock Is Getting Hammered.',
  'doc002': 'Among the best EV stocks to buy and watch, Tesla '
      '(TSLA.XNGS) is pulling back from new highs after a failed breakout '
      'above a \$1,201.05 double-bottom entry. ',
  'doc003': 'Meanwhile, Peloton reportedly finds an activist investor knocking '
      'on its door after a major stock crash fueled by strong indications of '
      'mismanagement. In a scathing new letter released Monday, activist '
      'Tesla Capital is pushing for Peloton to fire CEO, Chairman and '
      'founder John Foley and explore a sale.'
};

/// A dummy asynchronous term dictionary repository with 50 millisecond latency on
/// read/write operations to the [dictionary] and [postings].
///
/// Use for testing and examples.
class _TestIndex {
  //

  /// The [Dictionary] instance that is the data-store for the index's term
  /// dictionary
  final Dictionary dictionary = {};

  /// The [Dictionary] instance that is the data-store for the index's term
  /// dictionary
  final Postings postings = {};

  /// Implementation of [PostingsLoader].
  ///
  /// Returns a subset of [postings] corresponding to [terms].
  ///
  /// Simulates latency of 50 milliseconds.
  Future<Postings> loadTermPostings(Iterable<String> terms) async {
    final Postings retVal = {};
    for (final term in terms) {
      final entry = postings[term];
      if (entry != null) {
        retVal[term] = entry;
      }
    }
    return retVal;
  }

  /// Implementation of [DictionaryUpdater].
  ///
  /// Adds/overwrites the [values] to [dictionary].
  ///
  /// Simulates latency of 50 milliseconds.
  Future<void> updateDictionary(Dictionary values) async {
    /// Simulate write latency of 50milliseconds.
    await Future.delayed(const Duration(milliseconds: 50));
    dictionary.addAll(values);
  }

  /// Implementation of [PostingsUpdater].
  ///
  /// Adds/overwrites the [values] to [postings].
  ///
  /// Simulates latency of 50 milliseconds.
  Future<void> upsertTermPostings(Postings values) async {
    postings.addAll(values);
  }

  /// Implementation of [DictionaryLoader].
  ///
  /// Returns a subset of [dictionary] corresponding to [terms].
  ///
  /// Simulates latency of 50 milliseconds.
  Future<Dictionary> loadTerms(Iterable<String> terms) async {
    final Dictionary retVal = {};
    for (final term in terms) {
      final entry = dictionary[term];
      if (entry != null) {
        retVal[term] = entry;
      }
    }
    return retVal;
  }
}
