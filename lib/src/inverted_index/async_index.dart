// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/src/_index.dart';

/// The [AsyncCallbackIndex] is a [InvertedIndex] implementation class that
/// mixes in [InvertedIndexMixin] and [AsyncCallbackIndexMixin].
///
/// The InMemoryIndex is intended for working with a larger corpus and an
/// asynchronous index repository in persisted storage.  It uses asynchronous
/// callbacks to perform read and write operations on [DftMap], [KGramsMap]
/// and [PostingsMap] repositories.
class AsyncCallbackIndex
    with InvertedIndexMixin, AsyncCallbackIndexMixin
    implements InvertedIndex {
  //

  @override
  final int k;

  @override
  final NGramRange nGramRange;

  @override
  final VocabularySize dictionaryLengthLoader;

  @override
  final DftMapLoader dictionaryLoader;

  @override
  final DftMapUpdater dictionaryUpdater;

  @override
  final KGramsMapLoader kGramIndexLoader;

  @override
  final KGramsMapUpdater kGramIndexUpdater;

  @override
  final PostingsMapLoader postingsLoader;

  @override
  final PostingsMapUpdater postingsUpdater;

  /// Instantiates a [AsyncCallbackIndex] instance:
  /// - [tokenizer] is the [TextTokenizer] used to tokenize text for the index;
  /// - [k] is the length of k-gram entries in the k-gram index;
  /// - [nGramRange] is the range of N-gram lengths to generate;
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
  const AsyncCallbackIndex(
      {required this.dictionaryLoader,
      required this.dictionaryUpdater,
      required this.dictionaryLengthLoader,
      required this.kGramIndexLoader,
      required this.kGramIndexUpdater,
      required this.postingsLoader,
      required this.postingsUpdater,
      required this.tokenizer,
      this.k = 2,
      this.nGramRange = const NGramRange(1, 2),
      this.zones = const <String, double>{}});
  @override
  final TextTokenizer tokenizer;

  @override
  final ZoneWeightMap zones;

  @override
  Future<Ft> get vocabularyLength => dictionaryLengthLoader();
}

/// A mixin class that implements [InvertedIndex]. The mixin exposes five
/// callback function fields that must be overriden:
/// - [dictionaryLengthLoader] asynchronously retrieves the number of terms
///   in the vocabulary (N);
/// - [dictionaryLoader] asynchronously retrieves a [DftMap] for a vocabulary
///   from a index repository;
/// - [dictionaryUpdater] is callback that passes a [DftMap] subset
///    for persisting to a index repository;
/// - [kGramIndexLoader] asynchronously retrieves a [KGramsMap] for a vocabulary
///   from a index repository;
/// - [kGramIndexUpdater] is callback that passes a [KGramsMap] subset
///    for persisting to a index repository;
/// - [postingsLoader] asynchronously retrieves a [PostingsMap] for a vocabulary
///   from a index repository; and
/// - [postingsUpdater] passes a [PostingsMap] subset for persisting to a
///   index repository.
///
/// Provides implementation of the following methods for operations on
/// asynchronous [DftMap] and [PostingsMap] repositories:
/// - [vocabularyLength] calls [dictionaryLengthLoader].
/// - [getDictionary] calls [dictionaryLoader];
/// - [upsertDictionary ] calls [dictionaryUpdater];
/// - [getKGramIndex] calls [kGramIndexLoader];
/// - [upsertKGramIndex ] calls [kGramIndexUpdater];
/// - [getPostings] calls [postingsLoader]; and
/// - [upsertPostings] calls [postingsUpdater].
abstract class AsyncCallbackIndexMixin implements InvertedIndex {
  //

  /// Asynchronously retrieves the number of terms in the vocabulary (N).
  VocabularySize get dictionaryLengthLoader;

  /// Asynchronously retrieves a [DftMap] subset for a vocabulary from a
  /// [DftMap] index repository, usually persisted storage.
  DftMapLoader get dictionaryLoader;

  /// A callback that passes a subset of a [DftMap] containing new or
  /// changed [DftMapEntry] instances for persisting to the [DftMap]
  /// index repository.
  DftMapUpdater get dictionaryUpdater;

  /// Asynchronously retrieves a [KGramsMap] subset for a vocabulary from a
  /// [KGramsMap] index repository, usually persisted storage.
  KGramsMapLoader get kGramIndexLoader;

  /// A callback that passes a subset of a [KGramsMap] containing new or
  /// changed entries for persisting to the [KGramsMap] repository.
  KGramsMapUpdater get kGramIndexUpdater;

  /// Asynchronously retrieves a [PostingsMap] subset for a vocabulary from a
  /// [PostingsMap] index repository, usually persisted storage.
  PostingsMapLoader get postingsLoader;

  /// A callback that passes a subset of a [PostingsMap] containing new or changed
  /// [PostingsMapEntry] instances to the [PostingsMap] index repository.
  PostingsMapUpdater get postingsUpdater;

  @override
  Future<DftMap> getDictionary([Iterable<Term>? terms]) =>
      dictionaryLoader(terms);

  @override
  Future<void> upsertDictionary(DftMap values) => dictionaryUpdater(values);

  @override
  Future<KGramsMap> getKGramIndex([Iterable<Term>? terms]) =>
      kGramIndexLoader(terms);

  @override
  Future<void> upsertKGramIndex(KGramsMap values) => kGramIndexUpdater(values);

  @override
  Future<PostingsMap> getPostings(Iterable<Term> terms) =>
      postingsLoader(terms);

  @override
  Future<void> upsertPostings(PostingsMap values) => postingsUpdater(values);
}
