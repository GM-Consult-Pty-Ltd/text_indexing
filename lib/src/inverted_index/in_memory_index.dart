// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/text_indexing.dart';

/// The InMemoryIndex is an implementation of the [InvertedIndex] interface
/// that mixes in [InvertedIndexMixin] and [InMemoryIndexMixin].
///
/// The InMemoryIndex is intended for fast indexing of a smaller corpus using
/// in-memory dictionary, k-gram and postings hashmaps.
class InMemoryIndex
    with InMemoryIndexMixin, InvertedIndexMixin
    implements InvertedIndex {
  //

  @override
  final int k;

  @override
  late Dictionary dictionary;

  @override
  late KGramIndex kGramIndex;

  @override
  late Postings postings;

  /// Instantiates a [InMemoryIndex] instance:
  /// - [analyzer] is the [ITextAnalyzer] used to tokenize text for the index;
  /// - [k] is the length of k-gram entries in the k-gram index;
  /// - [zones] is a hashmap of zone names to their relative weight in the
  ///   index;
  /// - [phraseLength] is the maximum length of phrases in the index vocabulary
  ///   and must be greater than 0.
  /// - [dictionary] is the in-memory term dictionary for the indexer. Pass a
  ///   [Dictionary] instance at instantiation, otherwise an empty [Dictionary]
  ///   will be initialized;
  /// - [kGramIndex] is the in-memory [KGramIndex] for the index. Pass a
  ///   [KGramIndex] instance at instantiation, otherwise an empty [KGramIndex]
  ///   will be initialized; and
  /// - [postings] is the in-memory postings hashmap for the indexer. Pass a
  ///   [Postings] instance at instantiation, otherwise an empty [Postings]
  ///   will be initialized.
  InMemoryIndex(
      {Dictionary? dictionary,
      Postings? postings,
      KGramIndex? kGramIndex,
      this.analyzer = const TextAnalyzer(),
      this.k = 3,
      this.zones = const <String, double>{},
      this.phraseLength = 1})
      : assert(phraseLength > 0, 'The phrase length must be 1 or greater') {
    this.dictionary = dictionary ?? {};
    this.postings = postings ?? {};
    this.kGramIndex = kGramIndex ?? {};
  }

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
/// - [vocabularyLength] returns the number of entries in the in-memory
///   [dictionary].
/// - [getDictionary] retrieves a [Dictionary] for a collection of [Term]s from
///   the in-memory [dictionary] hashmap;
/// - [upsertDictionary ] inserts entries into the in-memory [dictionary] hashmap,
///   overwriting any existing entries;
/// - [getPostings] retrieves [Postings] for a collection of [Term]s from the
///   in-memory [postings] hashmap;
/// - [upsertPostings] inserts entries into the in-memory [postings] hashmap,
///   overwriting any existing entries;
/// - [getKGramIndex] retrieves entries for a collection of [Term]s from the
///   in-memory [kGramIndex] hashmap; and
/// - [upsertKGramIndex] inserts entries into the in-memory [kGramIndex] hashmap,
///   overwriting any existing entries.
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
