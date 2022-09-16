// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

// ignore_for_file: deprecated_member_use_from_same_package

import 'package:text_indexing/text_indexing.dart';

/// Asynchronously updates [Dictionary] and [Postings] data stores whenever a
/// document  is indexed.
///
/// Use the [index] method to index a text document, returning a list
/// of [DocumentPostingsEntry] and adding it to the [postingsStream].
///
/// The [loadTerms], [upsertDictionary], [loadTermPostings] and
/// [upsertTermPostings] implementations read and write from a [Dictionary]
/// and [Postings] using the [termsLoader], [dictionaryUpdater],
/// [postingsLoader] and [postingsUpdater] callback functions respectively:
/// - [termsLoader] synchronously retrieves a [Dictionary] for a vocabulary from
///   a data source;
/// - [dictionaryUpdater] is callback that passes a [Dictionary] subset
///    for persisting to a datastore;
/// - [postingsLoader] asynchronously retrieves a [Postings] for a vocabulary
///   from a data source; and
/// - [postingsUpdater] passes a [Postings] subset for persisting to a
///   datastore.
@Deprecated('Implemention class `PersistedIndexer` is deprecated, use factory '
    '`TextIndexer.async` instead.')
class PersistedIndexer extends TextIndexerBase {
  //

  /// Instantiates a [PersistedIndexer] instance:
  ///  - pass a [tokenizer] used by the indexer to parse  documents to tokens,
  ///   or use the default [TextIndexer.kDefaultTokenizer];
  /// - [termsLoader] synchronously retrieves a [Dictionary] for a vocabulary
  ///   from a data source;
  /// - [dictionaryUpdater] is callback that passes a [Dictionary] subset
  ///    for persisting to a datastore;
  /// - [postingsLoader] asynchronously retrieves a [Postings] for a vocabulary
  ///   from a data source; and
  /// - [postingsUpdater] passes a [Postings] subset for persisting to a
  ///   datastore.
  PersistedIndexer(
      {required DictionaryLoader termsLoader,
      required DictionaryUpdater dictionaryUpdater,
      required PostingsLoader postingsLoader,
      required PostingsUpdater postingsUpdater,
      this.tokenizer = TextIndexer.kDefaultTokenizer,
      this.jsonTokenizer = TextIndexer.kDefaultJsonTokenizer})
      : index = _PersistedIndex(
            termsLoader, dictionaryUpdater, postingsLoader, postingsUpdater);

  @override
  final Tokenizer tokenizer;

  @override
  final JsonTokenizer jsonTokenizer;

  @override
  final InvertedPositionalZoneIndex index;
}

/// An implementation class for the [PersistedIndexer], implementats
/// [InvertedPositionalZoneIndex] interface:
/// - [termsLoader] synchronously retrieves a [Dictionary] for a vocabulary
///   from a data source;
/// - [dictionaryUpdater] is callback that passes a [Dictionary] subset
///    for persisting to a datastore;
/// - [postingsLoader] asynchronously retrieves a [Postings] for a vocabulary
///   from a data source; and
/// - [postingsUpdater] passes a [Postings] subset for persisting to a
///   datastore.
class _PersistedIndex implements InvertedPositionalZoneIndex {
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

  /// Instantiates a [_PersistedIndex] instance:
  /// - [termsLoader] synchronously retrieves a [Dictionary] for a vocabulary
  ///   from a data source;
  /// - [dictionaryUpdater] is callback that passes a [Dictionary] subset
  ///    for persisting to a datastore;
  /// - [postingsLoader] asynchronously retrieves a [Postings] for a vocabulary
  ///   from a data source; and
  /// - [postingsUpdater] passes a [Postings] subset for persisting to a
  ///   datastore.
  _PersistedIndex(this.termsLoader, this.dictionaryUpdater, this.postingsLoader,
      this.postingsUpdater);

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
