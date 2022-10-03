// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'dart:math';
import 'package:text_indexing/src/_index.dart';

/// An interface that exposes methods for working with an inverted, positional
/// zoned index on a collection of documents:
/// - [phraseLength] is the maximum length of phrases in the index vocabulary.
///   The minimum phrase length is 1. If phrase length is greater than 1, the
///   index vocabulary also contains phrases up to [phraseLength] long,
///   concatenated from consecutive terms. The index size is increased by a
///   factor of [phraseLength];
/// - [tokenizer] is the [TextTokenizer] used to index the corpus terms;
/// - [vocabularyLength] is the number of unique terms in the corpus;
/// - [zones] is a hashmap of zone names to their relative weight in the index.
///   If [zones] is empty, all the `JSON` fields will be indexed;
/// - [k] is the length of k-gram entries in the k-gram index;
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

  /// The length of k-gram entries in the k-gram index.
  int get k;

  /// Maps zone names to their relative weight in the index.
  ///
  /// If [zones] is empty, all the `JSON` fields will be indexed.
  ZoneWeightMap get zones;

  /// The text analyser that extracts tokens from text for the index.
  TextTokenizer get tokenizer;

  /// The maximum length of phrases in the index vocabulary.
  ///
  /// Phrase length must be greater than 0.
  int get phraseLength;

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
  /// Default unnamed generative const constructor for sub-classes.
  const InvertedIndexBase();
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
