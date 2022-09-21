// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/text_indexing.dart';

/// An implementation of the [InvertedIndex] interface:
/// - [phraseLength] is the maximum length of phrases in the index vocabulary.
///   The minimum phrase length is 1. If phrase length is greater than 1, the
///   index vocabulary also contains phrases up to [phraseLength] long,
///   concatenated from consecutive terms. The index size is increased by a
///   factor of [phraseLength];
/// - [analyzer] is the [ITextAnalyzer] used to tokenize text for the index;
/// - [vocabularyLength] is the number of unique terms in the corpus;
/// - [zones] is a hashmap of zone names to their relative weight in the index;
/// - [k] is the length of k-gram entries in the k-gram index;
/// - [getDictionary] retrieves a [Dictionary] for a collection of [Term]s from
///   the in-memory [dictionary] hashmap;
/// - [upsertDictionary ] inserts entries into the in-memory [dictionary] hashmap,
///   overwriting any existing entries;
/// - [getKGramIndex] Asynchronously retrieves a [KGramIndex] for a collection
///   of [KGram]s from a [KGramIndex] repository;
/// - [upsertKGramIndex ] inserts entries into a [KGramIndex] repository,
///   overwriting any existing entries;
/// - [getPostings] retrieves [Postings] for a collection of [Term]s from the
///   in-memory [postings] hashmap;
/// - [upsertPostings] inserts entries into the in-memory [postings] hashmap,
///   overwriting any existing entries;
/// - [getFtdPostings] return a [FtdPostings] for a collection of [Term]s from
/// the [Postings], optionally filtered by minimum term frequency; and
/// - [getIdFtIndex] returns a [IdFtIndex] for a collection of [Term]s from
/// the [Dictionary].
/// - [dictionary] is the in-memory term dictionary for the indexer. Pass a
///   [dictionary] instance at instantiation, otherwise an empty [Dictionary]
///   will be initialized; and
/// - [postings] is the in-memory postings hashmap for the indexer. Pass a
///   [postings] instance at instantiation, otherwise an empty [Postings]
///   will be initialized.
class InMemoryIndex
    with InMemoryIndexMixin, InvertedIndexMixin
    implements InvertedIndex {
  //

  @override
  final int k;

  @override
  final Dictionary dictionary;

  @override
  final KGramIndex kGramIndex;

  @override
  final Postings postings;

  /// Instantiates a [InMemoryIndex] instance:
  /// - [analyzer] is the [ITextAnalyzer] used to tokenize text for the index;
  /// - [zones] is a hashmap of zone names to their relative weight in the index;
  /// - [dictionary] is the in-memory term dictionary for the indexer. Pass a
  ///   [dictionary] instance at instantiation, otherwise an empty [Dictionary]
  ///   will be initialized;
  /// - [postings] is the in-memory postings hashmap for the indexer. Pass a
  ///   [postings] instance at instantiation, otherwise an empty [Postings]
  ///   will be initialized; and
  /// - [phraseLength] is the maximum length of phrases in the index vocabulary.
  const InMemoryIndex(
      {required this.dictionary,
      required this.postings,
      required this.kGramIndex,
      required this.analyzer,
      this.k = 3,
      this.zones = const <String, double>{},
      this.phraseLength = 1})
      : assert(phraseLength > 0, 'The phrase length must be 1 or greater');

  @override
  final ITextAnalyzer analyzer;

  @override
  final ZoneWeightMap zones;

  @override
  final int phraseLength;
}

/// A mixin class that implements [InvertedIndex]. The mixin exposes in-memory
/// [dictionary] and [postings] fields that must be overriden. Provides
/// implementation of the following methods for operations on the in-memory
/// [postings] and [dictionary] maps:
/// - [vocabularyLength] returns the number of entries in [dictionary].
/// - [getDictionary] retrieves a [Dictionary] for a collection of [Term]s from
///   the in-memory [dictionary] hashmap;
/// - [upsertDictionary ] inserts entries into the in-memory [dictionary] hashmap,
///   overwriting any existing entries;
/// - [getPostings] retrieves [Postings] for a collection of [Term]s from the
///   in-memory [postings] hashmap;
/// - [upsertPostings] inserts entries into the in-memory [postings] hashmap,
///   overwriting any existing entries;
abstract class InMemoryIndexMixin implements InvertedIndex {
  //

  /// The in-memory term dictionary for the index.
  Dictionary get dictionary;

  /// The in-memory postings hashmap for the index.
  Postings get postings;

  /// The in-memory [KGramIndex] for the index.
  KGramIndex get kGramIndex;

  @override
  Future<Ft> get vocabularyLength async => dictionary.length;

  @override
  Future<Postings> getPostings(Iterable<Term> terms) async {
    final Postings retVal = {};
    for (final term in terms) {
      final entry = postings[term];
      if (entry != null) {
        retVal[term] = entry;
      }
    }
    return retVal;
  }

  @override
  Future<Dictionary> getDictionary([Iterable<Term>? terms]) async {
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
  Future<void> upsertDictionary(Dictionary values) async =>
      dictionary.addAll(values);

  @override
  Future<void> upsertPostings(Postings values) async => postings.addAll(values);

  @override
  Future<KGramIndex> getKGramIndex(Iterable<KGram> kGrams) async {
    final KGramIndex retVal = {};
    for (final kGram in kGrams) {
      final entry = kGramIndex[kGram];
      if (entry != null) {
        retVal[kGram] = entry;
      }
    }
    return retVal;
  }

  @override
  Future<void> upsertKGramIndex(KGramIndex values) async =>
      kGramIndex.addAll(values);
}
