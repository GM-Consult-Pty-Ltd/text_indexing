// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

part of 'text_indexing_test.dart';

/// A dummy asynchronous term dictionary repository with 50 millisecond latency on
/// read/write operations to the [dictionary] and [postings].
///
/// Use for testing and examples.
class _TestIndex with InvertedIndexMixin implements InvertedIndex {
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
  @override
  Future<Postings> getPostings(Iterable<String> terms) async {
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
  @override
  Future<void> upsertDictionary(Dictionary values) async {
    /// Simulate write latency of 50milliseconds.
    await Future.delayed(const Duration(milliseconds: 50));
    dictionary.addAll(values);
  }

  /// Implementation of [PostingsUpdater].
  ///
  /// Adds/overwrites the [values] to [postings].
  ///
  /// Simulates latency of 50 milliseconds.
  @override
  Future<void> upsertPostings(Postings values) async {
    /// Simulate write latency of 50milliseconds.
    await Future.delayed(const Duration(milliseconds: 50));
    postings.addAll(values);
  }

  /// Implementation of [DictionaryLoader].
  ///
  /// Returns a subset of [dictionary] corresponding to [terms].
  ///
  /// Simulates latency of 50 milliseconds.
  @override
  Future<Dictionary> getDictionary([Iterable<String>? terms]) async {
    if (terms == null) return dictionary;
    final Dictionary retVal = {};
    for (final term in terms) {
      final entry = dictionary[term];
      if (entry != null) {
        retVal[term] = entry;
      }
    }
    return retVal;
  }

  @override
  final ITextAnalyzer analyzer = TextAnalyzer();

  @override
  Future<Ft> get vocabularyLength async {
    /// Simulate write latency of 50milliseconds.
    await Future.delayed(const Duration(milliseconds: 50));
    return dictionary.length;
  }

  @override
  int get phraseLength => 3;

  @override
  final zones = {
    'name': 1.0,
    'description': 0.5,
    'hashTags': 2.0,
    'publicationDate': 0.1
  };
}
