// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'dart:async';

import 'package:text_indexing/text_indexing.dart';

/// The [CachedIndex] is a [InvertedIndex] implementation class that mixes in
/// [InvertedIndexMixin] and [CachedIndexMixin].
///
/// The [CachedIndex] is intended for working with a larger corpus with an
/// asynchronous index repository in persisted storage.  It uses asynchronous
/// callbacks to perform read and write operations on [Dictionary], [KGramIndex]
/// and [Postings] repositories, but keeps a cache of the most recent terms
/// and rarest k-grams in memory for faster indexing and searching.
///
/// [CachedIndexMixin] uses the in-memory [dictionaryCache], [kGramIndexCache]
/// and [postingsCache] hashmaps to cache [Dictionary], [KGramIndex] and
/// [Postings] maps retrieved via asynchronous callbacks ([dictionaryLoader],
/// [kGramIndexLoader] and [postingsLoader]).
class CachedIndex
    with CachedIndexMixin, InvertedIndexMixin
    implements InvertedIndex {
  //
  @override
  final TextTokenizer tokenizer;

  @override
  final ZoneWeightMap zones;

  @override
  final int phraseLength;

  @override
  final int cacheLimit;

  @override
  final int k;

  @override
  final Dictionary dictionaryCache = {};

  @override
  final KGramIndex kGramIndexCache = {};

  @override
  final Postings postingsCache = {};

  @override
  final DictionaryLengthLoader dictionaryLengthLoader;

  @override
  final DictionaryLoader dictionaryLoader;

  @override
  final DictionaryUpdater dictionaryUpdater;

  @override
  final KGramIndexLoader kGramIndexLoader;

  @override
  final KGramIndexUpdater kGramIndexUpdater;

  @override
  final PostingsLoader postingsLoader;

  @override
  final PostingsUpdater postingsUpdater;

  /// Instantiates a [InMemoryIndex] instance:
  /// - [tokenizer] is the [TextTokenizer] used to tokenize text for the index;
  /// - [k] is the length of k-gram entries in the k-gram index;
  /// - [zones] is a hashmap of zone names to their relative weight in the
  ///   index;
  /// - [phraseLength] is the maximum length of phrases in the index vocabulary
  ///   and must be greater than 0;
  /// - [cacheLimit] is the maximum number of entries in any of the caches;
  /// - [dictionaryCache] is the in-memory term dictionaryCache for the indexer. Pass a
  ///   [dictionaryCache] instance at instantiation, otherwise an empty [Dictionary]
  ///   will be initialized;
  /// - [dictionaryLengthLoader] asynchronously retrieves the number of terms
  ///   in the vocabulary (N);
  /// - [dictionaryLoader] asynchronously retrieves a [Dictionary] for a
  ///   vocabulary from a index repository;
  /// - [dictionaryUpdater] is callback that passes a [Dictionary] subset
  ///    for persisting to a index repository;
  /// - [kGramIndexLoader] asynchronously retrieves a [KGramIndex] for a
  ///   vocabulary from a index repository;
  /// - [kGramIndexUpdater] is callback that passes a [KGramIndex] subset
  ///    for persisting to a index repository;
  /// - [postingsLoader] asynchronously retrieves a [Postings] for a vocabulary
  ///   from a index repository; and
  /// - [postingsUpdater] passes a [Postings] subset for persisting to a
  ///   index repository.
  CachedIndex(
      {required this.dictionaryLoader,
      required this.dictionaryUpdater,
      required this.dictionaryLengthLoader,
      required this.kGramIndexLoader,
      required this.kGramIndexUpdater,
      required this.postingsLoader,
      required this.postingsUpdater,
      required this.tokenizer,
      this.cacheLimit = 10000,
      this.k = 3,
      this.zones = const <String, double>{},
      this.phraseLength = 1})
      : assert(phraseLength > 0, 'The phrase length must be 1 or greater');
}

/// A mixin class that implements [InvertedIndex]. The mixin uses the in-memory
/// [dictionaryCache], [kGramIndexCache] and [postingsCache] hashmaps to
/// cache [Dictionary], [KGramIndex] and [Postings] maps via asynchronous
/// callbacks.
///
/// [CachedIndexMixin] exposes the following fields that must be overridden by
/// classes that use this mixin:
/// - [dictionaryCache], [kGramIndexCache] and [postingsCache] hashmaps;
/// - [cacheLimit] is the maximum number of entries in any of the caches;
/// - [dictionaryLoader] asynchronously retrieves a [Dictionary] for a
///   vocabulary from a index repository;
/// - [dictionaryLengthLoader] asynchronously retrieves the number of terms in
///   the vocabulary (N);
/// - [dictionaryUpdater] is callback that passes a [Dictionary] subset
///    for persisting to a index repository;
/// - [kGramIndexLoader] asynchronously retrieves a [KGramIndex] for a
///   vocabulary from a index repository;
/// - [kGramIndexUpdater] is callback that passes a [KGramIndex] subset
///    for persisting to a index repository;
/// - [postingsLoader] asynchronously retrieves a [Postings] for a vocabulary
///   from a index repository; and
/// - [postingsUpdater] passes a [Postings] subset for persisting to a
///   index repository.
///
/// Provides implementation of the following methods for operations on the
/// in-memory [postingsCache], [kGramIndexCache] and [dictionaryCache] maps:
/// - [getDictionary] retrieves a [Dictionary] for a collection of [Term]s from
///   the in-memory [dictionaryCache] hashmap;
/// - [upsertDictionary ] inserts entries into the in-memory [dictionaryCache]
///   hashmap, overwriting any existing entries;
/// - [getPostings] retrieves [Postings] for a collection of [Term]s from the
///   in-memory [postingsCache] hashmap;
/// - [upsertPostings] inserts entries into the in-memory [postingsCache]
///   hashmap, overwriting any existing entries;
abstract class CachedIndexMixin implements InvertedIndex {
  //

  /// The maximum number of entries in any of the index caches.
  ///
  /// Cache lengths are maintained at or below [cacheLimit] using the following
  /// strategy:
  /// - the [dictionaryCache] keys are converted to a list and the last
  ///   [cacheLimit] keys are retained in [dictionaryCache]; and
  /// - the keys removed from [dictionaryCache] are also removed from the
  ///   [postingsCache].
  /// - the [kGramIndexCache] entries is sorted in ascending order of the
  ///   length of the terms and keys after [cacheLimit] are
  ///   removed from the [kGramIndexCache] to remove the most common k-grams.
  int get cacheLimit;

  /// Asynchronously retrieves the number of terms in the vocabulary (N).
  DictionaryLengthLoader get dictionaryLengthLoader;

  /// Asynchronously retrieves a [Dictionary] subset for a vocabulary from a
  /// [Dictionary] index repository, usually persisted storage.
  DictionaryLoader get dictionaryLoader;

  /// A callback that passes a subset of a [Dictionary] containing new or
  /// changed [DictionaryEntry] instances for persisting to the [Dictionary]
  /// index repository.
  DictionaryUpdater get dictionaryUpdater;

  /// Asynchronously retrieves a [KGramIndex] subset for a vocabulary from a
  /// [KGramIndex] index repository, usually persisted storage.
  KGramIndexLoader get kGramIndexLoader;

  /// A callback that passes a subset of a [KGramIndex] containing new or
  /// changed entries for persisting to the [KGramIndex] repository.
  KGramIndexUpdater get kGramIndexUpdater;

  /// Asynchronously retrieves a [Postings] subset for a vocabulary from a
  /// [Postings] index repository, usually persisted storage.
  PostingsLoader get postingsLoader;

  /// A callback that passes a subset of a [Postings] containing new or changed
  /// [PostingsEntry] instances to the [Postings] index repository.
  PostingsUpdater get postingsUpdater;

  /// The in-memory term dictionaryCache for the index.
  Dictionary get dictionaryCache;

  /// The in-memory postingsCache hashmap for the index.
  Postings get postingsCache;

  /// The in-memory [KGramIndex] for the index.
  KGramIndex get kGramIndexCache;

  @override
  Future<Ft> get vocabularyLength async => dictionaryCache.length;

  @override
  Future<Postings> getPostings(Iterable<Term> terms) async {
    final Postings retVal = {};
    final termsNotFound = <Term>{};
    for (final term in terms) {
      final entry = postingsCache[term];
      if (entry != null) {
        retVal[term] = entry;
      } else {
        termsNotFound.add(term);
      }
    }
    final persistedEntries = await postingsLoader(termsNotFound);
    shrinkPostingsCache(_getTermsToPurge(persistedEntries.length));
    postingsCache.addAll(persistedEntries);
    retVal.addAll(persistedEntries);
    return retVal;
  }

  @override
  Future<Dictionary> getDictionary([Iterable<Term>? terms]) async {
    if (terms == null) return dictionaryCache;
    final Dictionary retVal = {};
    final termsNotFound = <Term>{};
    for (final term in terms) {
      final entry = dictionaryCache[term];
      if (entry != null) {
        retVal[term] = entry;
      } else {
        termsNotFound.add(term);
      }
    }
    final persistedEntries = await dictionaryLoader(termsNotFound);
    shrinkDictionaryCache(_getTermsToPurge(persistedEntries.length));
    dictionaryCache.addAll(persistedEntries);
    retVal.addAll(persistedEntries);
    return retVal;
  }

  @override
  Future<void> upsertDictionary(Dictionary values) async {
    unawaited(dictionaryUpdater(values));
    shrinkDictionaryCache(_getTermsToPurge(values.length));
    dictionaryCache.addAll(values);
  }

  @override
  Future<void> upsertPostings(Postings values) async {
    unawaited(postingsUpdater(values));
    shrinkPostingsCache(_getTermsToPurge(values.length));
    postingsCache.addAll(values);
  }

  @override
  Future<KGramIndex> getKGramIndex(Iterable<KGram> kGrams) async {
    final KGramIndex retVal = {};
    final entriesNotFound = <KGram>{};
    for (final kGram in kGrams) {
      final entry = kGramIndexCache[kGram];
      if (entry != null) {
        retVal[kGram] = entry;
      } else {
        entriesNotFound.add(kGram);
      }
    }
    final persistedEntries = await kGramIndexLoader(entriesNotFound);
    shrinkKGramIndexCache(persistedEntries.length);
    kGramIndexCache.addAll(persistedEntries);
    return retVal;
  }

  @override
  Future<void> upsertKGramIndex(KGramIndex values) async {
    unawaited(kGramIndexUpdater(values));
    shrinkKGramIndexCache(values.length);
    kGramIndexCache.addAll(values);
  }

  /// Shrinks the [kGramIndexCache] to [cacheLimit].
  ///
  /// The [kGramIndexCache] entries is sorted in ascending order of the
  /// length of the terms set value length and keys after
  /// [cacheLimit] - [shrinkBy] are removed from the [kGramIndexCache], leaving
  /// the least frequent entries.
  void shrinkKGramIndexCache(int shrinkBy) {
    if (kGramIndexCache.length > cacheLimit) {
      final entriesToRemove =
          List<MapEntry<String, Set<Term>>>.from(kGramIndexCache.entries);
      entriesToRemove
          .sort(((a, b) => a.value.length.compareTo(b.value.length)));
      final keysToRemove =
          entriesToRemove.sublist(cacheLimit - shrinkBy).map((e) => e.key);
      kGramIndexCache.removeWhere((key, value) => keysToRemove.contains(key));
    }
  }

  // /// Shrinks the [dictionaryCache] and [postingsCache] to [cacheLimit]:
  // /// - the [dictionaryCache] keys are converted to a list and the last
  // ///   [cacheLimit] keys are retained in [dictionaryCache]; and
  // /// - the keys removed from [dictionaryCache] are also removed from the
  // ///   [postingsCache].
  // void shrinkDictionaryAndPostingsCaches(int shrinkBy) {
  //   if (dictionaryCache.length > cacheLimit &&
  //       postingsCache.length > cacheLimit) {
  //     // get the terms to remove
  //     final terms = _getTermsToPurge(shrinkBy);
  //     // remove the entries from the cache
  //     postingsCache.removeWhere((key, value) => terms.contains(key));
  //     // remove the entries from the cache
  //     dictionaryCache.removeWhere((key, value) => terms.contains(key));
  //   }
  // }

  /// Shrinks the [dictionaryCache] and [postingsCache] to [cacheLimit]:
  /// - the [dictionaryCache] keys are converted to a list and the last
  ///   [cacheLimit] keys are retained in [dictionaryCache]; and
  /// - the keys removed from [dictionaryCache] are also removed from the
  ///   [postingsCache].
  void shrinkPostingsCache(Iterable<Term> terms) =>
      dictionaryCache.removeWhere((key, value) => terms.contains(key));

  /// Shrinks the [dictionaryCache] and [postingsCache] to [cacheLimit]:
  /// - the [dictionaryCache] keys are converted to a list and the last
  ///   [cacheLimit] keys are retained in [dictionaryCache]; and
  /// - the keys removed from [dictionaryCache] are also removed from the
  ///   [postingsCache].
  void shrinkDictionaryCache(Iterable<Term> terms) =>
      dictionaryCache.removeWhere((key, value) => terms.contains(key));

  /// The [dictionaryCache] keys are converted to a list and the last
  /// [cacheLimit] keys returned.
  Iterable<Term> _getTermsToPurge(int shrinkBy) {
    if (dictionaryCache.length < cacheLimit + 1) return [];
    return dictionaryCache.keys.toList().sublist(0, shrinkBy);
  }
}
