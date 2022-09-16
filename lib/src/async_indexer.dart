// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

// ignore_for_file: deprecated_member_use_from_same_package

import 'package:rxdart/rxdart.dart';
import 'package:text_indexing/text_indexing.dart';

/// Implementation of [TextIndexer] that uses asynchronous callbacks to perform
/// read and write operations on a [Dictionary] and [Postings].
class AsyncIndexer extends TextIndexerBase {
  //

  /// Instantiates a [AsyncIndexer] instance:
  /// - pass a custom [tokenizer] to parse text to tokens, or use the default
  ///   [TextIndexer.kDefaultTokenizer];
  /// - pass a custom [jsonTokenizer] used to parse JSON documents to tokens,
  ///   or use the default [TextIndexer.kDefaultJsonTokenizer];
  /// - [termsLoader] asynchronously retrieves a [Dictionary] for a vocabulary
  ///   from a data source;
  /// - [dictionaryUpdater] is callback that passes a [Dictionary] subset
  ///    for persisting to a datastore;
  /// - [postingsLoader] asynchronously retrieves a [Postings] for a vocabulary
  ///   from a data source; and
  /// - [postingsUpdater] passes a [Postings] subset for persisting to a
  ///   datastore.
  AsyncIndexer(
      {required DictionaryLoader termsLoader,
      required DictionaryUpdater dictionaryUpdater,
      required PostingsLoader postingsLoader,
      required PostingsUpdater postingsUpdater,
      this.tokenizer = TextIndexer.kDefaultTokenizer,
      this.jsonTokenizer = TextIndexer.kDefaultJsonTokenizer})
      : index = AsyncCallbackIndex(
            termsLoader, dictionaryUpdater, postingsLoader, postingsUpdater);

  @override
  final Tokenizer tokenizer;

  @override
  final JsonTokenizer jsonTokenizer;

  @override
  final InvertedPositionalZoneIndex index;

  @override
  final controller = BehaviorSubject<Postings>();
}

/// The [AsyncCallbackIndex] is a [InvertedPositionalZoneIndex] implementation class
/// that uses asynchronous callbacks to perform read and write operations on
/// [Dictionary] and [Postings] repositories:
/// - [termsLoader] synchronously retrieves a [Dictionary] for a vocabulary
///   from a data source;
/// - [dictionaryUpdater] is callback that passes a [Dictionary] subset
///    for persisting to a datastore;
/// - [postingsLoader] asynchronously retrieves a [Postings] for a vocabulary
///   from a data source; and
/// - [postingsUpdater] passes a [Postings] subset for persisting to a
///   datastore.
class AsyncCallbackIndex implements InvertedPositionalZoneIndex {
  //

  /// Asynchronously retrieves a [Dictionary] subset for a vocabulary from a
  /// [Dictionary] data source, usually persisted storage.
  final DictionaryLoader termsLoader;

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
  /// - [termsLoader] synchronously retrieves a [Dictionary] for a vocabulary
  ///   from a data source;
  /// - [dictionaryUpdater] is callback that passes a [Dictionary] subset
  ///    for persisting to a datastore;
  /// - [postingsLoader] asynchronously retrieves a [Postings] for a vocabulary
  ///   from a data source; and
  /// - [postingsUpdater] passes a [Postings] subset for persisting to a
  ///   datastore.
  AsyncCallbackIndex(this.termsLoader, this.dictionaryUpdater,
      this.postingsLoader, this.postingsUpdater);

  @override
  Future<Dictionary> getDictionary([Iterable<Term>? terms]) =>
      termsLoader(terms);
  @override
  Future<Postings> getPostings(Iterable<Term> terms) => postingsLoader(terms);

  @override
  Future<void> upsertDictionary(Dictionary values) => dictionaryUpdater(values);

  @override
  Future<void> upsertPostings(Postings values) => postingsUpdater(values);
}
