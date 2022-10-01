// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/src/_index.dart';

/// The [AsyncCallbackIndex] is a [InvertedIndex] implementation class that
/// mixes in [InvertedIndexMixin] and [AsyncCallbackIndexMixin].
///
/// The InMemoryIndex is intended for working with a larger corpus and an
/// asynchronous index repository in persisted storage.  It uses asynchronous
/// callbacks to perform read and write operations on [Dictionary], [KGramIndex]
/// and [Postings] repositories.
class AsyncCallbackIndex
    with InvertedIndexMixin, AsyncCallbackIndexMixin
    implements InvertedIndex {
  //

  @override
  final int k;

  @override
  final int phraseLength;

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

  /// Instantiates a [AsyncCallbackIndex] instance:
  /// - [tokenizer] is the [TextTokenizer] used to tokenize text for the index;
  /// - [k] is the length of k-gram entries in the k-gram index;
  /// - [zones] is a hashmap of zone names to their relative weight in the
  ///   index;
  /// - [phraseLength] is the maximum length of phrases in the index vocabulary
  ///   and must be greater than 0;
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
  const AsyncCallbackIndex(
      {required this.dictionaryLoader,
      required this.dictionaryUpdater,
      required this.dictionaryLengthLoader,
      required this.kGramIndexLoader,
      required this.kGramIndexUpdater,
      required this.postingsLoader,
      required this.postingsUpdater,
      required this.tokenizer,
      this.k = 3,
      this.zones = const <String, double>{},
      this.phraseLength = 1})
      : assert(phraseLength > 0, 'The phrase length must be 1 or greater');

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
///
/// Provides implementation of the following methods for operations on
/// asynchronous [Dictionary] and [Postings] repositories:
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

  @override
  Future<Dictionary> getDictionary([Iterable<Term>? terms]) =>
      dictionaryLoader(terms);

  @override
  Future<void> upsertDictionary(Dictionary values) => dictionaryUpdater(values);

  @override
  Future<KGramIndex> getKGramIndex([Iterable<Term>? terms]) =>
      kGramIndexLoader(terms);

  @override
  Future<void> upsertKGramIndex(KGramIndex values) => kGramIndexUpdater(values);

  @override
  Future<Postings> getPostings(Iterable<Term> terms) => postingsLoader(terms);

  @override
  Future<void> upsertPostings(Postings values) => postingsUpdater(values);
}
