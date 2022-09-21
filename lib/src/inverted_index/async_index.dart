// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

// ignore_for_file: deprecated_member_use_from_same_package

import 'package:text_indexing/text_indexing.dart';

/// The [AsyncCallbackIndex] is a [InvertedIndex] implementation class
/// that uses asynchronous callbacks to perform read and write operations on
/// [Dictionary] and [Postings] repositories:
/// - [phraseLength] is the maximum length of phrases in the index vocabulary.
///   The minimum phrase length is 1. If phrase length is greater than 1, the
///   index vocabulary also contains phrases up to [phraseLength] long,
///   concatenated from consecutive terms. The index size is increased by a
///   factor of [phraseLength];
/// - [analyzer] is the [ITextAnalyzer] used to tokenize text for the index;
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
/// - [getFtdPostings] return a [FtdPostings] for a collection of [Term]s from
///   the [Postings], optionally filtered by minimum term frequency; and
/// - [getIdFtIndex] returns a [IdFtIndex] for a collection of [Term]s from
///   the [Dictionary];
/// - [dictionaryLoader] asynchronously retrieves a [Dictionary] for a vocabulary
///   from a data source;
/// - [dictionaryLengthLoader] asynchronously retrieves the number of terms in
///   the vocabulary (N);
/// - [dictionaryUpdater] is callback that passes a [Dictionary] subset
///    for persisting to a datastore;
/// - [kGramIndexLoader] asynchronously retrieves a [KGramIndex] for a vocabulary
///   from a data source;
/// - [kGramIndexUpdater] is callback that passes a [KGramIndex] subset
///    for persisting to a datastore;
/// - [postingsLoader] asynchronously retrieves a [Postings] for a vocabulary
///   from a data source; and
/// - [postingsUpdater] passes a [Postings] subset for persisting to a
///   datastore.
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

  /// A callback that passes a subset of a [Postings] containing new or changed
  /// [PostingsEntry] instances to the [Postings] datastore.
  @override
  final PostingsUpdater postingsUpdater;

  /// Instantiates a [AsyncCallbackIndex] instance:
  /// - [phraseLength] is the maximum length of phrases in the index vocabulary.
  ///   The minimum phrase length is 1. If phrase length is greater than 1, the
  ///   index vocabulary also contains phrases up to [phraseLength] long,
  ///   concatenated from consecutive terms. The index size is increased by a
  ///   factor of [phraseLength];
  /// - [analyzer] is the [ITextAnalyzer] used to tokenize text for the index;
  /// - [vocabularyLength] is the number of unique terms in the corpus;
  /// - [zones] is a hashmap of zone names to their relative weight in the index;
  /// - [k] is the length of k-gram entries in the k-gram index;
  /// - [dictionaryLengthLoader] asynchronously retrieves the number of terms
  ///   in the vocabulary (N);
  /// - [dictionaryLoader] asynchronously retrieves a [Dictionary] for a vocabulary
  ///   from a data source;
  /// - [dictionaryUpdater] is callback that passes a [Dictionary] subset
  ///    for persisting to a datastore;
  /// - [kGramIndexLoader] asynchronously retrieves a [KGramIndex] for a vocabulary
  ///   from a data source;
  /// - [kGramIndexUpdater] is callback that passes a [KGramIndex] subset
  ///    for persisting to a datastore;
  /// - [postingsLoader] asynchronously retrieves a [Postings] for a vocabulary
  ///   from a data source; and
  /// - [postingsUpdater] passes a [Postings] subset for persisting to a
  ///   datastore.
  const AsyncCallbackIndex(
      {required this.dictionaryLoader,
      required this.dictionaryUpdater,
      required this.dictionaryLengthLoader,
      required this.kGramIndexLoader,
      required this.kGramIndexUpdater,
      required this.postingsLoader,
      required this.postingsUpdater,
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
  Future<Ft> get vocabularyLength => dictionaryLengthLoader();
}

/// A mixin class that implements [InvertedIndex]. The mixin exposes five
/// callback function fields that must be overriden:
/// - [dictionaryLengthLoader] asynchronously retrieves the number of terms
///   in the vocabulary (N);
/// - [dictionaryLoader] asynchronously retrieves a [Dictionary] for a vocabulary
///   from a data source;
/// - [dictionaryUpdater] is callback that passes a [Dictionary] subset
///    for persisting to a datastore;
/// - [kGramIndexLoader] asynchronously retrieves a [KGramIndex] for a vocabulary
///   from a data source;
/// - [kGramIndexUpdater] is callback that passes a [KGramIndex] subset
///    for persisting to a datastore;
/// - [postingsLoader] asynchronously retrieves a [Postings] for a vocabulary
///   from a data source; and
/// - [postingsUpdater] passes a [Postings] subset for persisting to a
///   datastore.
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
  /// [Dictionary] data source, usually persisted storage.
  DictionaryLoader get dictionaryLoader;

  /// A callback that passes a subset of a [Dictionary] containing new or
  /// changed [DictionaryEntry] instances for persisting to the [Dictionary]
  /// datastore.
  DictionaryUpdater get dictionaryUpdater;

  /// Asynchronously retrieves a [KGramIndex] subset for a vocabulary from a
  /// [KGramIndex] data source, usually persisted storage.
  KGramIndexLoader get kGramIndexLoader;

  /// A callback that passes a subset of a [KGramIndex] containing new or
  /// changed entries for persisting to the [KGramIndex] repository.
  KGramIndexUpdater get kGramIndexUpdater;

  /// Asynchronously retrieves a [Postings] subset for a vocabulary from a
  /// [Postings] data source, usually persisted storage.
  PostingsLoader get postingsLoader;

  /// A callback that passes a subset of a [Postings] containing new or changed
  /// [PostingsEntry] instances to the [Postings] datastore.
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
