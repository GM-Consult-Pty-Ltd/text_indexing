// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

part of 'text_indexing_test.dart';

/// A dummy asynchronous term dictionary repository with 50 millisecond latency on
/// read/write operations to the [dictionary] and [postings].
///
/// Use for testing and examples.
class _TestIndexRepository {
  //

  /// The [Dictionary] instance that is the data-store for the index's term
  /// dictionary
  final Dictionary dictionary = {};

  /// The [Dictionary] instance that is the data-store for the index's term
  /// dictionary
  final Postings postings = {};

  final KGramIndex kGramIndex = {};

  /// Returns a subset of [postings] corresponding to [terms].
  ///
  /// Simulates latency of 100 uS per term in [terms].
  Future<Postings> getPostings(Iterable<String> terms) async {
    final Postings retVal = {};
    for (final term in terms) {
      final entry = postings[term];
      if (entry != null) {
        retVal[term] = entry;
      }
    }
    // await Future.delayed(
    //     Duration(milliseconds: (((terms.length / 10).floor() / 10).floor())));
    return retVal;
  }

  /// Adds/overwrites the [values] to [dictionary].
  ///
  /// Simulates latency of 100 uS  per entry.
  Future<void> upsertDictionary(Dictionary values) async {
    /// Simulate latency of 100 uS  per entry.
    // await Future.delayed(Duration(milliseconds: (values.length / 10).floor()));
    dictionary.addAll(values);
  }

  /// Adds/overwrites the [values] to [postings].
  ///
  /// Simulates latency of 100 uS  per entry.
  Future<void> upsertPostings(Postings values) async {
    /// Simulate write latency of 100 uS  per entry.
    // await Future.delayed(Duration(milliseconds: (values.length / 10).floor()));
    postings.addAll(values);
  }

  /// Returns a subset of [dictionary] corresponding to [terms].
  ///
  /// Simulates latency of 100 uS  per term in [terms].
  Future<Dictionary> getDictionary([Iterable<String>? terms]) async {
    terms = terms ?? kGramIndex.keys;
    final Dictionary retVal = {};
    for (final term in terms) {
      final entry = dictionary[term];
      if (entry != null) {
        retVal[term] = entry;
      }
    }
    // await Future.delayed(Duration(milliseconds: ((terms.length / 10).floor())));
    return retVal;
  }

  /// Returns a subset of [kGramIndex] corresponding to [kGrams].
  ///
  /// Simulates latency of 100 uS  per entry.
  Future<KGramIndex> getKGramIndex([Iterable<KGram>? kGrams]) async {
    kGrams = kGrams ?? kGramIndex.keys;
    final KGramIndex retVal = {};
    for (final kGram in kGrams) {
      final entry = kGramIndex[kGram];
      if (entry != null) {
        retVal[kGram] = entry;
      }
    }
    // await Future.delayed(
    //     Duration(milliseconds: ((kGrams.length / 10).floor())));
    return retVal;
  }

  Future<void> upsertKGramIndex(KGramIndex values) async =>
      kGramIndex.addAll(values);

  /// Returns the length of the [dictionary].
  ///
  /// Simulate a read latency of 5 milliseconds.
  Future<Ft> get vocabularyLength async {
    /// Simulate a read latency of 5 milliseconds.
    // await Future.delayed(const Duration(milliseconds: 5));
    return dictionary.length;
  }
}
