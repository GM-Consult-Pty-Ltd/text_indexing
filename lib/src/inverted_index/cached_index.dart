// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'dart:async';

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
/// - [cacheLimit] is the maximum number of entries in any of the caches;
/// - [getDictionary] retrieves a [Dictionary] for a collection of [Term]s from
///   the in-memory [dictionaryCache] hashmap;
/// - [upsertDictionary ] inserts entries into the in-memory [dictionaryCache] hashmap,
///   overwriting any existing entries;
/// - [getKGramIndex] Asynchronously retrieves a [KGramIndex] for a collection
///   of [KGram]s from a [KGramIndex] repository;
/// - [upsertKGramIndex ] inserts entries into a [KGramIndex] repository,
///   overwriting any existing entries;
/// - [getPostings] retrieves [Postings] for a collection of [Term]s from the
///   in-memory [postingsCache] hashmap;
/// - [upsertPostings] inserts entries into the in-memory [postingsCache] hashmap,
///   overwriting any existing entries;
/// - [getFtdPostings] return a [FtdPostings] for a collection of [Term]s from
/// the [Postings], optionally filtered by minimum term frequency; and
/// - [getIdFtIndex] returns a [IdFtIndex] for a collection of [Term]s from
/// the [Dictionary].
/// - [dictionaryCache] is the in-memory term dictionaryCache for the indexer. Pass a
///   [dictionaryCache] instance at instantiation, otherwise an empty [Dictionary]
///   will be initialized; and
/// - [postingsCache] is the in-memory postingsCache hashmap for the indexer. Pass a
///   [postingsCache] instance at instantiation, otherwise an empty [Postings]
///   will be initialized.
class CachedIndex
    with CachedIndexMixin, InvertedIndexMixin
    implements InvertedIndex {
  //
  @override
  final ITextAnalyzer analyzer;

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
  /// - [analyzer] is the [ITextAnalyzer] used to tokenize text for the index;
  /// - [cacheLimit] is the maximum number of entries in any of the caches;
  /// - [zones] is a hashmap of zone names to their relative weight in the index;
  /// - [dictionaryCache] is the in-memory term dictionaryCache for the indexer. Pass a
  ///   [dictionaryCache] instance at instantiation, otherwise an empty [Dictionary]
  ///   will be initialized;
  /// - [phraseLength] is the maximum length of phrases in the index vocabulary.
  /// - [dictionaryLengthLoader] asynchronously retrieves the number of terms
  ///   in the vocabulary (N);
  /// - [dictionaryLoader] asynchronously retrieves a [Dictionary] for a vocabulary
  ///   from a index repository;
  /// - [dictionaryUpdater] is callback that passes a [Dictionary] subset
  ///    for persisting to a index repository;
  /// - [kGramIndexLoader] asynchronously retrieves a [KGramIndex] for a vocabulary
  ///   from a index repository;
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
      required this.analyzer,
      this.cacheLimit = 10000,
      this.k = 3,
      this.zones = const <String, double>{},
      this.phraseLength = 1})
      : assert(phraseLength > 0, 'The phrase length must be 1 or greater');
}

/// A mixin class that implements [InvertedIndex]. The mixin exposes in-memory
/// [dictionaryCache] and [postingsCache] fields that must be overriden.  It
/// exposes the following fields that must be overridden by classes that use
/// this mixin:
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
/// Provides implementation of the following methods for operations on the in-memory
/// [postingsCache] and [dictionaryCache] maps:
/// - [getDictionary] retrieves a [Dictionary] for a collection of [Term]s from
///   the in-memory [dictionaryCache] hashmap;
/// - [upsertDictionary ] inserts entries into the in-memory [dictionaryCache] hashmap,
///   overwriting any existing entries;
/// - [getPostings] retrieves [Postings] for a collection of [Term]s from the
///   in-memory [postingsCache] hashmap;
/// - [upsertPostings] inserts entries into the in-memory [postingsCache] hashmap,
///   overwriting any existing entries;
abstract class CachedIndexMixin implements InvertedIndex {
  //

  /// The maximum number of entries in any of the index caches.
  ///
  /// Cache lengths are maintained at or below [cacheLimit] using the following
  /// strategy:
  /// - the [dictionaryCache] entries are sorted in descending
  ///   order of document frequency and keys after [cacheLimit] are removed
  ///   from [dictionaryCache];
  /// - the keys removed from [dictionaryCache] are also removed from the
  ///   [postingsCache]; and
  /// - the [kGramIndexCache] entries is sorted in descending order of the
  ///   length of the terms set value length and keys after [cacheLimit] are
  ///   removed from the [kGramIndexCache].
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
    for (final term in terms) {
      final entry = postingsCache[term];
      if (entry != null) {
        retVal[term] = entry;
      }
    }
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
    dictionaryCache.addAll(persistedEntries);
    retVal.addAll(persistedEntries);
    return retVal;
  }

  @override
  Future<void> upsertDictionary(Dictionary values) async {
    dictionaryCache.addAll(values);
    unawaited(dictionaryUpdater(values));
    await shrinkDictionaryAndPostingsCaches();
  }

  @override
  Future<void> upsertPostings(Postings values) async {
    postingsCache.addAll(values);
    unawaited(postingsUpdater(values));
    await shrinkDictionaryAndPostingsCaches();
  }

  @override
  Future<KGramIndex> getKGramIndex(Iterable<KGram> kGrams) async {
    final KGramIndex retVal = {};
    for (final kGram in kGrams) {
      final entry = kGramIndexCache[kGram];
      if (entry != null) {
        retVal[kGram] = entry;
      }
    }
    return retVal;
  }

  @override
  Future<void> upsertKGramIndex(KGramIndex values) async {
    kGramIndexCache.addAll(values);
    unawaited(kGramIndexUpdater(values));
    await shrinkKGramIndexCache();
  }

  /// Shrinks the [kGramIndexCache] to [cacheLimit].
  ///
  /// The [kGramIndexCache] entries is sorted in descending order of the
  /// length of the terms set value length and keys after [cacheLimit] are
  /// removed from the [kGramIndexCache].
  Future<void> shrinkKGramIndexCache() async {
    if (kGramIndexCache.length > cacheLimit) {
      final entriesToRemove =
          List<MapEntry<String, Set<Term>>>.from(kGramIndexCache.entries);
      entriesToRemove
          .sort(((a, b) => b.value.length.compareTo(a.value.length)));
      final keysToRemove =
          entriesToRemove.sublist(cacheLimit).map((e) => e.key);
      kGramIndexCache.removeWhere((key, value) => keysToRemove.contains(key));
    }
  }

  /// Shrinks the [dictionaryCache] and [postingsCache] to [cacheLimit]:
  /// - the [dictionaryCache] entries are sorted in descending
  ///   order of document frequency and keys after [cacheLimit] are removed
  ///   from [dictionaryCache]; and
  /// - the keys removed from [dictionaryCache] are also removed from the
  ///   [postingsCache].
  Future<void> shrinkDictionaryAndPostingsCaches() async {
    if (dictionaryCache.length > cacheLimit &&
        postingsCache.length > cacheLimit) {
      // get the terms to remove
      final terms = _getTermsToPurge();
      // initialize the map of postings to remove
      final Postings postingsToRemove = {};
      // initialize the map of dictionary entries to remove
      final Dictionary dictionaryEntriesToRemove = {};
      // iterate through the terms to remove
      for (final term in terms) {
        // get the postings entry for term from the cache
        final posting = postingsCache[term];
        if (posting != null) {
          // add the postings entry to the remove list
          postingsToRemove[term] = posting;
        }
        // get the dictionary entry for term from the cache
        final dictEntry = dictionaryCache[term];
        if (dictEntry != null) {
          // add the dictionary entry to the remove list
          dictionaryEntriesToRemove[term] = dictEntry;
        }
      }
      // remove the entries from the cache
      postingsCache.removeWhere((key, value) => terms.contains(key));
      // remove the entries from the cache
      dictionaryCache.removeWhere((key, value) => terms.contains(key));
    }
  }

  /// [dictionaryCache] entries are sorted in descending order of document
  /// frequency and the keys after [cacheLimit] are returned.
  Iterable<Term> _getTermsToPurge() {
    if (dictionaryCache.length < cacheLimit + 1) return [];
    final orderedDictionary =
        List<DictionaryEntry>.from(dictionaryCache.entries)
          ..sort(((a, b) => b.value.compareTo(a.value)));
    final termsToRemove = orderedDictionary.sublist(cacheLimit);
    return termsToRemove.map((e) => e.key);
  }
}
