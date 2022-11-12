// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'dart:math';
import 'package:text_indexing/src/_index.dart';

/// An interface that exposes methods for working with an inverted, positional
/// zoned index on a collection of documents.
/// - [analyzer] is the [TextAnalyzer] used to index the corpus terms.
/// - [vocabularyLength] is the number of unique terms in the corpus.
/// - [zones] is a hashmap of zone names to their relative weight in the index.
///   If [zones] is empty, all the `JSON` fields will be indexed.
/// - [k] is the length of k-gram entries in the k-gram index.
/// - [nGramRange] is the range of N-gram lengths to generate. The minimum
///   n-gram length is 1. If n-gram length is greater than 1, the
///   index vocabulary also contains n-grams up to [nGramRange].max long,
///   concatenated from consecutive terms. The index size is increased by a
///   factor of [nGramRange].max.
/// - [strategy] is the tokenizing strategy to use when tokenizing documents
///   for indexing.
/// - [getDictionary] Asynchronously retrieves a [DftMap] for a collection
///   of [Term]s from a [DftMap] repository.
/// - [upsertDictionary ] inserts entries into a [DftMap] repository,
///   overwriting any existing entries.
/// - [getKGramIndex] Asynchronously retrieves a [KGramsMap] for a collection
///   of [KGram]s from a [KGramsMap] repository.
/// - [upsertKGramIndex ] inserts entries into a [KGramsMap] repository,
///   overwriting any existing entries.
/// - [getPostings] asynchronously retrieves [PostingsMap] for a collection
///   of [Term]s from a [PostingsMap] repository.
/// - [upsertPostings] inserts entries into a [PostingsMap] repository,
///   overwriting any existing entries.
/// The following static methods are used to work with [PostingsMap] and
/// [DftMap] objects.
/// - [tfIndexFromPostings] returns a hashmap of [Term] to [Ft] for the terms
///   in a [PostingsMap], where [Ft] is the number of times each of the terms
///   occurs in the `corpus`.
/// - [ftdPostingsFromPostings] returns a [FtdPostings] for a collection of
///   [Term]s from a [PostingsMap], optionally filtered by minimum term
///   frequency.
/// - [idFtIndexFromDictionary] returns a [IdFtIndex] for a collection of
///   [Term]s from a [DftMap].
abstract class InvertedIndex {
  //

  /// A factory constructor that returns an [InMemoryIndex] instance.
  /// - [analyzer] is the [TextAnalyzer] used to tokenize text for the index.
  /// - [collectionSize] is the size of the indexed collection.
  /// - [tokenFilter] is a filter function that returns a subset of a
  ///   collection of [Token]s.
  /// - [k] is the length of k-gram entries in the k-gram index.
  /// - [strategy] is the tokenizing strategy to use when tokenizing documents
  ///   for indexing.
  /// - [nGramRange] is the range of N-gram lengths to generate.
  /// - [zones] is a hashmap of zone names to their relative weight in the
  ///   index.
  /// - [dictionary] is the in-memory term dictionary for the indexer. Pass a
  ///   [DftMap] instance at instantiation, otherwise an empty [DftMap]
  ///   will be initialized.
  /// - [kGramIndex] is the in-memory [KGramsMap] for the index. Pass a
  ///   [KGramsMap] instance at instantiation, otherwise an empty [KGramsMap]
  ///   will be initialized.
  /// - [postings] is the in-memory postings hashmap for the indexer. Pass a
  ///   [PostingsMap] instance at instantiation, otherwise an empty [PostingsMap]
  ///   will be initialized.
  factory InvertedIndex.inMemory(
          {required TextAnalyzer analyzer,
          required int collectionSize,
          TokenFilter? tokenFilter,
          Map<String, int>? dictionary,
          Map<String, Map<String, Map<String, List<int>>>>? postings,
          KeywordPostingsMap? keywordPostings,
          Map<String, Set<String>>? kGramIndex,
          int k = 2,
          NGramRange nGramRange = const NGramRange(1, 2),
          TokenizingStrategy strategy = TokenizingStrategy.terms,
          Map<String, double> zones = const <String, double>{}}) =>
      InMemoryIndex(
          collectionSize: collectionSize,
          analyzer: analyzer,
          tokenFilter: tokenFilter,
          // keywordExtractor: keywordExtractor,
          dictionary: dictionary,
          postings: postings,
          keywordPostings: keywordPostings,
          kGramIndex: kGramIndex,
          k: k,
          strategy: strategy,
          nGramRange: nGramRange,
          zones: zones);

  /// /// A factory constructor that returns an [AsyncCallbackIndex] instance.
  /// - [analyzer] is the [TextAnalyzer] used to tokenize text for the index.
  /// - [tokenFilter] is a filter function that returns a subset of a
  ///   collection of [Token]s.
  /// - [k] is the length of k-gram entries in the k-gram index.
  /// - [strategy] is the tokenizing strategy to use when tokenizing documents
  ///   for indexing.
  /// - [nGramRange] is the range of N-gram lengths to generate.
  /// - [zones] is a hashmap of zone names to their relative weight in the
  ///   index.
  /// - [dictionaryLengthLoader] asynchronously retrieves the number of terms
  ///   in the vocabulary (N).
  /// - [dictionaryLoader] asynchronously retrieves a [DftMap] for a
  ///   vocabulary from a index repository.
  /// - [dictionaryUpdater] is callback that passes a [DftMap] subset
  ///    for persisting to a index repository.
  /// - [kGramIndexLoader] asynchronously retrieves a [KGramsMap] for a
  ///   vocabulary from a index repository.
  /// - [kGramIndexUpdater] is callback that passes a [KGramsMap] subset
  ///    for persisting to a index repository.
  /// - [postingsLoader] asynchronously retrieves a [PostingsMap] for a vocabulary
  ///   from a index repository.
  /// - [postingsUpdater] passes a [PostingsMap] subset for persisting to a
  ///   index repository.
  factory InvertedIndex(
          {required CollectionSizeCallback collectionSizeLoader,
          required DftMapLoader dictionaryLoader,
          required DftMapUpdater dictionaryUpdater,
          required CollectionSizeCallback dictionaryLengthLoader,
          required KGramsMapLoader kGramIndexLoader,
          required KGramsMapUpdater kGramIndexUpdater,
          required PostingsMapLoader postingsLoader,
          required PostingsMapUpdater postingsUpdater,
          required KeywordPostingsMapLoader keywordPostingsLoader,
          required KeywordPostingsMapUpdater keywordPostingsUpdater,
          required TextAnalyzer analyzer,
          TokenFilter? tokenFilter,
          Map<String, int>? dictionary,
          Map<String, Map<String, Map<String, List<int>>>>? postings,
          Map<String, Set<String>>? kGramIndex,
          int k = 2,
          NGramRange nGramRange = const NGramRange(1, 2),
          TokenizingStrategy strategy = TokenizingStrategy.terms,
          Map<String, double> zones = const <String, double>{}}) =>
      AsyncCallbackIndex(
          collectionSizeLoader: collectionSizeLoader,
          dictionaryLoader: dictionaryLoader,
          dictionaryUpdater: dictionaryUpdater,
          dictionaryLengthLoader: dictionaryLengthLoader,
          kGramIndexLoader: kGramIndexLoader,
          kGramIndexUpdater: kGramIndexUpdater,
          postingsLoader: postingsLoader,
          postingsUpdater: postingsUpdater,
          keywordPostingsLoader: keywordPostingsLoader,
          keywordPostingsUpdater: keywordPostingsUpdater,
          analyzer: analyzer,
          tokenFilter: tokenFilter,
          k: k,
          nGramRange: nGramRange,
          strategy: strategy,
          zones: zones);

  /// The length of k-gram entries in the k-gram index.
  int get k;

  /// A filter function that returns a subset of a collection of [Token]s.
  ///
  /// Used to manipulate the [analyzer]'s tokenizer output.
  TokenFilter? get tokenFilter;

  ///The strategy to apply when splitting text to [Token]s.
  TokenizingStrategy get strategy;

  /// The minimum and maximum length of n-grams in the index.
  NGramRange? get nGramRange;

  /// Maps zone names to their relative weight in the index.
  ///
  /// If [zones] is empty, all the `JSON` fields will be indexed.
  ZoneWeightMap get zones;

  /// The text analyser that extracts tokens from text for the index.
  TextAnalyzer get analyzer;

  // /// A splitter function that returns an ordered collection of keyword phrases
  // /// from text.
  // KeywordExtractor get keywordExtractor;

  /// Returns the number of terms in the vocabulary (N).
  Future<Ft> get vocabularyLength;

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

  /// Asynchronously retrieves [PostingsMapEntry] entities for the [terms] from a
  /// [PostingsMap] repository.
  ///
  /// Used in `index-elimination`, to return a subset of the [PostingsMap]
  /// where the key ([Term]) is in [keywords].
  Future<KeywordPostingsMap> getKeywordPostings(Iterable<Term> keywords);

  /// Inserts [values] into a [PostingsMap] repository, overwriting them if they
  /// already exist.
  Future<void> upsertKeywordPostings(KeywordPostingsMap values);

  /// Asynchronously returns the total number of documents in the indexed
  /// collection.
  Future<int> getCollectionSize();

  /// Returns a map of terms to hashmaps of [DocId] to [Ft].
  ///
  /// Iterates over the [postings] to map the document ids to the document term
  /// frequency for the document.
  ///
  /// Filters the [postings] by [minFtd], the minimum term frequency in the
  /// document. The default [minFtd] is 1 and it cannot be less than 1. Provide
  /// [minFtd] greater than 1 for more agressive index-elimination in tiered
  /// indexes.
  static FtdPostings ftdPostingsFromPostings(PostingsMap postings,
      [Ft minFtd = 1]) {
    assert(minFtd > 0, '[minFtd] must be greater than zero.');
    final FtdPostings ftdPostings = {};
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

  /// Returns a map of terms to inverse document frequency (double) from the
  /// [dictionary].
  static IdFtIndex idFtIndexFromDictionary(DftMap dictionary, int n) {
    return dictionary.map((key, value) => MapEntry(key, log(n / value)));
  }

  // /// Returns a map of terms to inverse document frequency (double) from the
  // /// [postings].
  // ///
  // /// Applies the weighting in [zones] if not null.
  // static IdFtIndex idFtIndexFromPostings(PostingsMap postings, int n,
  //     [ZoneWeightMap? zones]) {
  //   final Map<String, double> dictionary = {};
  //   for (final termPosting in postings.entries) {
  //     var tF = 0.0;
  //     for (final docPosting in termPosting.value.entries) {
  //       var dTf = 0;
  //       for (final fieldPositions in docPosting.value.values) {
  //         dTf += fieldPositions.length;
  //       }
  //       tF += dTf;
  //     }
  //     if (tF > 0) {
  //       dictionary[termPosting.key] = tF;
  //     }
  //   }
  //   return dictionary.map((key, value) => MapEntry(key, log(n / value)));
  // }

  /// Returns a hashmap of term to weighted document term frequency by iterating
  /// over the [postings] to aggregate the document frequency for the term.
  ///
  /// If [zones] is null, all occurrences of term will be weighted as 1.0.
  ///
  /// If [zones] is not null, the term frequency in a zone is multiplied by
  /// the weight for the zone.  If a zone is not present in the keys in [zones]
  /// then the term frequency in that zone will be excluded.
  static Map<String, double> docTermFrequencies(PostingsMap postings,
      [ZoneWeightMap? zones]) {
    final Map<String, double> tfIndex = {};
    for (final termPosting in postings.entries) {
      var tF = 0.0;
      for (final docPosting in termPosting.value.entries) {
        var dTf = 0.0;
        for (final zonePostings in docPosting.value.entries) {
          final fieldPositions = zonePostings.value;
          final zone = zonePostings.key;
          final wZ = zones == null ? 1.0 : zones[zone] ?? 0.0;
          dTf += fieldPositions.length * wZ;
        }
        tF += dTf;
      }
      if (tF > 0) {
        tfIndex[termPosting.key] = tF;
      }
    }
    return tfIndex;
  }

  /// Returns a [DftMap] by iterating over the [postings] to aggregate the
  /// document frequency for the term.
  static DftMap tfIndexFromPostings(PostingsMap postings) {
    final Map<String, Ft> tfIndex = {};
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
