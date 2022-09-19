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
/// - [analyzer] is the [ITextAnalyzer] used to index the corpus terms;
/// - [vocabularyLength] is the number of unique terms in the corpus;
/// - [getDictionary] Asynchronously retrieves a [Dictionary] for a collection
///   of [Term]s from a [Dictionary] repository;
/// - [upsertDictionary ] inserts entries into a [Dictionary] repository,
///   overwriting any existing entries;
/// - [getPostings] asynchronously retrieves [Postings] for a collection
///   of [Term]s from a [Postings] repository;
/// - [upsertPostings] inserts entries into a [Postings] repository,
///   overwriting any existing entries;
/// - [getFtdPostings] return a [FtdPostings] for a collection of [Term]s from
/// the [Postings], optionally filtered by minimum term frequency; and
/// - [getIdFtIndex] returns a [IdFtIndex] for a collection of [Term]s from
/// the [Dictionary].
/// - [dictionaryLoader] asynchronously retrieves a [Dictionary] for a vocabulary
///   from a data source;
/// - [dictionaryLengthLoader] asynchronously retrieves the number of terms in
///   the vocabulary (N);
/// - [dictionaryUpdater] is callback that passes a [Dictionary] subset
///    for persisting to a datastore;
/// - [postingsLoader] asynchronously retrieves a [Postings] for a vocabulary
///   from a data source; and
/// - [postingsUpdater] passes a [Postings] subset for persisting to a
///   datastore.
class AsyncCallbackIndex with InvertedIndexMixin implements InvertedIndex {
  //

  @override
  final int phraseLength;

  /// Asynchronously retrieves the number of terms in the vocabulary (N).
  final DictionaryLengthLoader dictionaryLengthLoader;

  /// Asynchronously retrieves a [Dictionary] subset for a vocabulary from a
  /// [Dictionary] data source, usually persisted storage.
  final DictionaryLoader dictionaryLoader;

  /// A callback that passes a subset of a [Dictionary] containing new or
  /// changed [DictionaryEntry] instances for persisting to the [Dictionary]
  /// datastore.
  final DictionaryUpdater dictionaryUpdater;

  /// Asynchronously retrieves a [Postings] subset for a vocabulary from a
  /// [Postings] data source, usually persisted storage.
  final PostingsLoader postingsLoader;

  /// A callback that passes a subset of a [Postings] containing new or changed
  /// [PostingsEntry] instances to the [Postings] datastore.
  final PostingsUpdater postingsUpdater;

  /// Instantiates a [AsyncCallbackIndex] instance:
  /// - [analyzer] is the [ITextAnalyzer] used to tokenize text for the index;
  /// - [dictionaryLoader] synchronously retrieves a [Dictionary] for a vocabulary
  ///   from a data source;
  /// - [dictionaryUpdater] is callback that passes a [Dictionary] subset
  ///    for persisting to a datastore;
  /// - [postingsLoader] asynchronously retrieves a [Postings] for a vocabulary
  ///   from a data source; and
  /// - [postingsUpdater] passes a [Postings] subset for persisting to a
  ///   datastore.
  const AsyncCallbackIndex(
      {required this.dictionaryLoader,
      required this.dictionaryUpdater,
      required this.dictionaryLengthLoader,
      required this.postingsLoader,
      required this.postingsUpdater,
      required this.analyzer,
      this.phraseLength = 1})
      : assert(phraseLength > 0, 'The phrase length must be 1 or greater');

  @override
  Future<Dictionary> getDictionary([Iterable<Term>? terms]) =>
      dictionaryLoader(terms);
  @override
  Future<Postings> getPostings(Iterable<Term> terms) => postingsLoader(terms);

  @override
  Future<void> upsertDictionary(Dictionary values) => dictionaryUpdater(values);

  @override
  Future<void> upsertPostings(Postings values) => postingsUpdater(values);

  @override
  final ITextAnalyzer analyzer;

  @override
  Future<Ft> get vocabularyLength => dictionaryLengthLoader();
}
