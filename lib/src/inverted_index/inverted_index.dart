// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'dart:math';
import 'package:text_indexing/src/_index.dart';

/// An interface that exposes methods for working with an inverted, positional
/// zoned index on a collection of documents:
/// - [tokenizer] is the [TextTokenizer] used to index the corpus terms;
/// - [vocabularyLength] is the number of unique terms in the corpus;
/// - [zones] is a hashmap of zone names to their relative weight in the index.
///   If [zones] is empty, all the `JSON` fields will be indexed;
/// - [k] is the length of k-gram entries in the k-gram index;
/// - [nGramRange] is the range of N-gram lengths to generate. The minimum
///   n-gram length is 1. If n-gram length is greater than 1, the
///   index vocabulary also contains n-grams up to [nGramRange].max long,
///   concatenated from consecutive terms. The index size is increased by a
///   factor of [nGramRange].max;
/// - [getDictionary] Asynchronously retrieves a [DftMap] for a collection
///   of [Term]s from a [DftMap] repository;
/// - [upsertDictionary ] inserts entries into a [DftMap] repository,
///   overwriting any existing entries;
/// - [getKGramIndex] Asynchronously retrieves a [KGramsMap] for a collection
///   of [KGram]s from a [KGramsMap] repository;
/// - [upsertKGramIndex ] inserts entries into a [KGramsMap] repository,
///   overwriting any existing entries;
/// - [getPostings] asynchronously retrieves [PostingsMap] for a collection
///   of [Term]s from a [PostingsMap] repository;
/// - [upsertPostings] inserts entries into a [PostingsMap] repository,
///   overwriting any existing entries;
/// - [getTfIndex] returns hashmap of [Term] to [Ft] for a collection of
///   [Term]s, where [Ft] is the number of times each of the terms occurs in
///   the `corpus`;
/// - [getFtdPostings] return a [FtdPostings] for a collection of [Term]s from
///   the [PostingsMap], optionally filtered by minimum term frequency; and
/// - [getIdFtIndex] returns a [IdFtIndex] for a collection of [Term]s from
///   the [DftMap].
abstract class InvertedIndex {
  //

  /// A factory constructor that returns an [InMemoryIndex] instance:
  /// - [tokenizer] is the [TextTokenizer] used to tokenize text for the index;
  /// - [k] is the length of k-gram entries in the k-gram index;
  /// - [zones] is a hashmap of zone names to their relative weight in the
  ///   index;
  /// - [dictionary] is the in-memory term dictionary for the indexer. Pass a
  ///   [DftMap] instance at instantiation, otherwise an empty [DftMap]
  ///   will be initialized;
  /// - [kGramIndex] is the in-memory [KGramsMap] for the index. Pass a
  ///   [KGramsMap] instance at instantiation, otherwise an empty [KGramsMap]
  ///   will be initialized; and
  /// - [postings] is the in-memory postings hashmap for the indexer. Pass a
  ///   [PostingsMap] instance at instantiation, otherwise an empty [PostingsMap]
  ///   will be initialized.
  factory InvertedIndex.inMemory(
          {required TextTokenizer tokenizer,
          Map<String, int>? dictionary,
          Map<String, Map<String, Map<String, List<int>>>>? postings,
          Map<String, Set<String>>? kGramIndex,
          int k = 2,
          NGramRange nGramRange = const NGramRange(1, 2),
          Map<String, double> zones = const <String, double>{}}) =>
      InMemoryIndex(
          tokenizer: tokenizer,
          dictionary: dictionary,
          postings: postings,
          kGramIndex: kGramIndex,
          k: k,
          nGramRange: nGramRange,
          zones: zones);

  /// /// A factory constructor that returns an [AsyncCallbackIndex] instance:
  /// - [tokenizer] is the [TextTokenizer] used to tokenize text for the index;
  /// - [k] is the length of k-gram entries in the k-gram index;
  /// - [zones] is a hashmap of zone names to their relative weight in the
  ///   index;
  /// - [dictionaryLengthLoader] asynchronously retrieves the number of terms
  ///   in the vocabulary (N);
  /// - [dictionaryLoader] asynchronously retrieves a [DftMap] for a
  ///   vocabulary from a index repository;
  /// - [dictionaryUpdater] is callback that passes a [DftMap] subset
  ///    for persisting to a index repository;
  /// - [kGramIndexLoader] asynchronously retrieves a [KGramsMap] for a
  ///   vocabulary from a index repository;
  /// - [kGramIndexUpdater] is callback that passes a [KGramsMap] subset
  ///    for persisting to a index repository;
  /// - [postingsLoader] asynchronously retrieves a [PostingsMap] for a vocabulary
  ///   from a index repository; and
  /// - [postingsUpdater] passes a [PostingsMap] subset for persisting to a
  ///   index repository.
  factory InvertedIndex(
          {required Future<Map<String, int>> Function([Iterable<String>?])
              dictionaryLoader,
          required Future<void> Function(Map<String, int>) dictionaryUpdater,
          required Future<int> Function() dictionaryLengthLoader,
          required Future<Map<String, Set<String>>> Function(
                  [Iterable<String>?])
              kGramIndexLoader,
          required Future<void> Function(Map<String, Set<String>>)
              kGramIndexUpdater,
          required Future<Map<String, Map<String, Map<String, List<int>>>>>
                  Function(Iterable<String>)
              postingsLoader,
          required Future<void> Function(
                  Map<String, Map<String, Map<String, List<int>>>>)
              postingsUpdater,
          required TextTokenizer tokenizer,
          Map<String, int>? dictionary,
          Map<String, Map<String, Map<String, List<int>>>>? postings,
          Map<String, Set<String>>? kGramIndex,
          int k = 2,
          NGramRange nGramRange = const NGramRange(1, 2),
          Map<String, double> zones = const <String, double>{}}) =>
      AsyncCallbackIndex(
          dictionaryLoader: dictionaryLoader,
          dictionaryUpdater: dictionaryUpdater,
          dictionaryLengthLoader: dictionaryLengthLoader,
          kGramIndexLoader: kGramIndexLoader,
          kGramIndexUpdater: kGramIndexUpdater,
          postingsLoader: postingsLoader,
          postingsUpdater: postingsUpdater,
          tokenizer: tokenizer,
          k: k,
          nGramRange: nGramRange,
          zones: zones);

  /// The length of k-gram entries in the k-gram index.
  int get k;

  /// The minimum and maximum length of n-grams in the index.
  NGramRange get nGramRange;

  /// Maps zone names to their relative weight in the index.
  ///
  /// If [zones] is empty, all the `JSON` fields will be indexed.
  ZoneWeightMap get zones;

  /// The text analyser that extracts tokens from text for the index.
  TextTokenizer get tokenizer;

  /// Returns the number of terms in the vocabulary (N).
  Future<Ft> get vocabularyLength;

  /// Returns a map of [terms] to hashmaps of [DocId] to [Ft]
  ///
  /// Used in `index-elimination` to return a [FtdPostings] for [terms] from
  /// the [PostingsMap].
  ///
  /// Filters the [FtdPostings] by [minFtd], the minimum term frequency in the
  /// document. The default [minFtd] is 1 and it cannot be less than 1. Provide
  /// [minFtd] greater than 1 for more agressive index-elimination in tiered
  /// indexes.
  Future<FtdPostings> getFtdPostings(Iterable<Term> terms, [Ft minFtd = 1]);

  /// Returns a map of [terms] to hashmaps of [DocId] to [Ft].
  ///
  /// Used in `index-elimination`, to return a [IdFtIndex] for [terms] from
  /// the [DftMap].
  Future<IdFtIndex> getIdFtIndex(Iterable<Term> terms);

  /// Returns a hashmap of [Term] to [Ft] for the [terms], where [Ft] is
  /// the number of times each of [terms] occurs in the `corpus`.
  Future<DftMap> getTfIndex(Iterable<Term> terms);

  /// Asynchronously retrieves a [DftMap] for the [terms] from a
  /// [DftMap] repository.
  ///
  /// Loads the entire [DftMap] if [terms] is null.
  ///
  /// Used in `index-elimination`, to return a subset of [DftMap] where the
  /// key ([Term]) is in [terms].
  Future<DftMap> getDictionary([Iterable<Term>? terms]);

  /// Inserts [values] into a [DftMap] repository, overwriting them if they
  /// already exist.
  Future<void> upsertDictionary(DftMap values);

  /// Asynchronously retrieves a [KGramsMap] for the [terms] from a
  /// [KGramsMap] repository.
  ///
  /// Loads the entire [KGramsMap] if [terms] is null.
  ///
  /// Used in `index-elimination`, to return a subset of the [KGramsMap]
  /// where the key ([KGram]) is in [kGrams].
  Future<KGramsMap> getKGramIndex(Iterable<KGram> kGrams);

  /// Inserts [values] into a [KGramsMap] repository, overwriting any existing
  /// entries.
  Future<void> upsertKGramIndex(KGramsMap values);

  /// Asynchronously retrieves [PostingsMapEntry] entities for the [terms] from a
  /// [PostingsMap] repository.
  ///
  /// Used in `index-elimination`, to return a subset of the [PostingsMap]
  /// where the key ([Term]) is in [terms].
  Future<PostingsMap> getPostings(Iterable<Term> terms);

  /// Inserts [values] into a [PostingsMap] repository, overwriting them if they
  /// already exist.
  Future<void> upsertPostings(PostingsMap values);
}

/// An abstract [InvertedIndex] base class that mixies in [InvertedIndexMixin].
///
/// Provides a default unnamed generative const constructor for sub-classes.
abstract class InvertedIndexBase with InvertedIndexMixin {
  //

  /// Default unnamed generative const constructor for sub-classes.
  const InvertedIndexBase();

  //
}

/// A mixin that implements the [InvertedIndex.getTfIndex],
/// [InvertedIndex.getFtdPostings] and [InvertedIndex.getIdFtIndex] methods.
abstract class InvertedIndexMixin implements InvertedIndex {
//

  /// Implements [InvertedIndex.getFtdPostings] method:
  /// - loads a subset of [PostingsMap] for [terms] by calling [getPostings].
  /// - iterates over the loaded [PostingsMap] to map the document ids to the
  ///   document term frequency for the document.
  @override
  Future<FtdPostings> getFtdPostings(Iterable<Term> terms,
      [Ft minFtd = 1]) async {
    assert(minFtd > 0, '[minFtd] must be greater than zero.');
    final FtdPostings ftdPostings = {};
    final postings = await getPostings(terms);
    for (final termPosting in postings.entries) {
      final docPostings = <DocId, int>{};
      for (final docPosting in termPosting.value.entries) {
        final docId = docPosting.key;
        var ft = 0;
        for (final fieldPositions in docPosting.value.values) {
          ft += fieldPositions.length;
        }
        if (ft >= minFtd) {
          docPostings[docId] = ft;
        }
      }
      if (docPostings.isNotEmpty) {
        ftdPostings[termPosting.key] = docPostings;
      }
    }

    return ftdPostings;
  }

  /// Implements [InvertedIndex.getFtdPostings] method:
  /// - gets the [vocabularyLength] (N);
  /// - gets the [DftMap] for [terms] by calling [getDictionary]; then
  /// - maps the [DftMap] values (dTf) to inverse document frequency by
  ///   calculating log(N/dTf).
  @override
  Future<IdFtIndex> getIdFtIndex(Iterable<Term> terms) async {
    final dictionary = await getDictionary(terms);
    final n = await vocabularyLength;
    return dictionary.map((key, value) => MapEntry(key, log(n / value)));
  }

  /// Implements [InvertedIndex.getTfIndex] method:
  /// - loads a subset of [PostingsMap] for [terms] by calling [getPostings].
  /// - iterates over the loaded [PostingsMap] to map aggregate the postings for
  ///  the term.
  @override
  Future<DftMap> getTfIndex(Iterable<Term> terms) async {
    final Map<String, Ft> tfIndex = {};
    final postings = await getPostings(terms);
    for (final termPosting in postings.entries) {
      var tF = 0;
      for (final docPosting in termPosting.value.entries) {
        var dTf = 0;
        for (final fieldPositions in docPosting.value.values) {
          dTf += fieldPositions.length;
        }
        tF += dTf;
      }
      if (tF > 0) {
        tfIndex[termPosting.key] = tF;
      }
    }
    return tfIndex;
  }
}
