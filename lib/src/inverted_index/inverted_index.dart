// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'dart:math';
import 'package:text_indexing/text_indexing.dart';

/// An alias for [int], used to denote the frequency of a [Term] in an index or
/// indexed object.
typedef Ft = int;

/// Alias for `Map<Zone, double>`.
///
/// Maps the zone names to their relative weight.
typedef ZoneWeightMap = Map<Zone, double>;

/// Alias for [double] where it represents the inverse document frequency of a
/// term.
///
/// IdFt is defined as `idft = log (N / dft)`, where:
/// - N is the total number of terms in the index;
/// - dft is the document frequency of the term (number of documents that
///   contain the term).
/// The [IdFt] of a rare term is high, whereas the [IdFt] of a frequent term is
/// likely to be low.
typedef IdFt = double;

/// Alias for `Map<String, Map<String, int>>`.
///
/// Maps the vocabulary to hashmaps of document id to term frequency in the
/// document.
typedef FtdPostings = Map<Term, Map<DocId, Ft>>;

/// An interface that exposes methods for working with an inverted, positional
/// zoned index on a collection of documents:
/// - [phraseLength] is the maximum length of phrases in the index vocabulary.
///   The minimum phrase length is 1. If phrase length is greater than 1, the
///   index vocabulary also contains phrases up to [phraseLength] long,
///   concatenated from consecutive terms. The index size is increased by a
///   factor of [phraseLength];
/// - [analyzer] is the [ITextAnalyzer] used to index the corpus terms;
/// - [vocabularyLength] is the number of unique terms in the corpus;
/// - [zones] is a hashmap of zone names to their relative weight in the index;
/// - [k] is the length of k-gram entries in the k-gram index;
/// - [getDictionary] Asynchronously retrieves a [Dictionary] for a collection
///   of [Term]s from a [Dictionary] repository;
/// - [upsertDictionary ] inserts entries into a [Dictionary] repository,
///   overwriting any existing entries;
/// - [getKGramIndex] Asynchronously retrieves a [KGramIndex] for a collection
///   of [KGram]s from a [KGramIndex] repository;
/// - [upsertKGramIndex ] inserts entries into a [KGramIndex] repository,
///   overwriting any existing entries;
/// - [getPostings] asynchronously retrieves [Postings] for a collection
///   of [Term]s from a [Postings] repository;
/// - [upsertPostings] inserts entries into a [Postings] repository,
///   overwriting any existing entries;
/// - [getTfIndex] returns hashmap of [Term] to [Ft] for a collection of
///   [Term]s, where [Ft] is the number of times each of the terms occurs in
///   the `corpus`;
/// - [getFtdPostings] return a [FtdPostings] for a collection of [Term]s from
///   the [Postings], optionally filtered by minimum term frequency; and
/// - [getIdFtIndex] returns a [IdFtIndex] for a collection of [Term]s from
///   the [Dictionary].
abstract class InvertedIndex {
  //

  /// The length of k-gram entries in the k-gram index.
  int get k;

  /// Maps zone names to their relative weight in the index.
  ///
  /// If [zones] is empty, all the `JSON` fields will be indexed.
  ZoneWeightMap get zones;

  /// The text analyser that extracts tokens from text for the index.
  ITextAnalyzer get analyzer;

  /// The maximum length of phrases in the index vocabulary.
  ///
  /// Phrase length must be greater than 0.
  int get phraseLength;

  /// Returns the number of terms in the vocabulary (N).
  Future<Ft> get vocabularyLength;

  /// Returns a map of [terms] to hashmaps of [DocId] to [Ft]
  ///
  /// Used in `index-elimination` to return a [FtdPostings] for [terms] from
  /// the [Postings].
  ///
  /// Filters the [FtdPostings] by [minFtd], the minimum term frequency in the
  /// document. The default [minFtd] is 1 and it cannot be less than 1. Provide
  /// [minFtd] greater than 1 for more agressive index-elimination in tiered
  /// indexes.
  Future<FtdPostings> getFtdPostings(Iterable<Term> terms, [Ft minFtd = 1]);

  /// Returns a map of [terms] to hashmaps of [DocId] to [Ft].
  ///
  /// Used in `index-elimination`, to return a [IdFtIndex] for [terms] from
  /// the [Dictionary].
  Future<IdFtIndex> getIdFtIndex(Iterable<Term> terms);

  /// Returns a hashmap of [Term] to [Ft] for the [terms], where [Ft] is
  /// the number of times each of [terms] occurs in the `corpus`.
  Future<Dictionary> getTfIndex(Iterable<Term> terms);

  /// Asynchronously retrieves a [Dictionary] for the [terms] from a
  /// [Dictionary] repository.
  ///
  /// Loads the entire [Dictionary] if [terms] is null.
  ///
  /// Used in `index-elimination`, to return a subset of [Dictionary] where the
  /// key ([Term]) is in [terms].
  Future<Dictionary> getDictionary([Iterable<Term>? terms]);

  /// Inserts [values] into a [Dictionary] repository, overwriting them if they
  /// already exist.
  Future<void> upsertDictionary(Dictionary values);

  /// Asynchronously retrieves a [KGramIndex] for the [terms] from a
  /// [KGramIndex] repository.
  ///
  /// Loads the entire [KGramIndex] if [terms] is null.
  ///
  /// Used in `index-elimination`, to return a subset of the [KGramIndex]
  /// where the key ([KGram]) is in [kGrams].
  Future<KGramIndex> getKGramIndex(Iterable<KGram> kGrams);

  /// Inserts [values] into a [KGramIndex] repository, overwriting any existing
  /// entries.
  Future<void> upsertKGramIndex(KGramIndex values);

  /// Asynchronously retrieves [PostingsEntry] entities for the [terms] from a
  /// [Postings] repository.
  ///
  /// Used in `index-elimination`, to return a subset of the [Postings]
  /// where the key ([Term]) is in [terms].
  Future<Postings> getPostings(Iterable<Term> terms);

  /// Inserts [values] into a [Postings] repository, overwriting them if they
  /// already exist.
  Future<void> upsertPostings(Postings values);
}

/// A mixin that implements the [InvertedIndex.getTfIndex],
/// [InvertedIndex.getFtdPostings] and [InvertedIndex.getIdFtIndex] methods.
abstract class InvertedIndexMixin implements InvertedIndex {
//

  /// Implements [InvertedIndex.getFtdPostings] method:
  /// - loads a subset of [Postings] for [terms] by calling [getPostings].
  /// - iterates over the loaded [Postings] to map the document ids to the
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
  /// - gets the [Dictionary] for [terms] by calling [getDictionary]; then
  /// - maps the [Dictionary] values (dTf) to inverse document frequency by
  ///   calculating log(N/dTf).
  @override
  Future<IdFtIndex> getIdFtIndex(Iterable<Term> terms) async {
    final dictionary = await getDictionary(terms);
    final n = await vocabularyLength;
    return dictionary.map((key, value) => MapEntry(key, log(n / value)));
  }

  /// Implements [InvertedIndex.getTfIndex] method:
  /// - loads a subset of [Postings] for [terms] by calling [getPostings].
  /// - iterates over the loaded [Postings] to map aggregate the postings for
  ///  the term.
  @override
  Future<Dictionary> getTfIndex(Iterable<Term> terms) async {
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
