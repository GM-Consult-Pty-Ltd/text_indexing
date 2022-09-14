// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/text_indexing.dart';

/// Asynchronously updates [Dictionary] and [Postings] data stores whenever a
/// document  is indexed.
///
/// Use the [index] method to index a text document, returning a list
/// of [PostingsList] and adding it to the [postingsStream].
///
/// The [loadTerms], [updateDictionary], [loadTermPostings] and
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
  PersistedIndexer({
    required this.termsLoader,
    required this.dictionaryUpdater,
    required this.postingsLoader,
    required this.postingsUpdater,
    this.tokenizer = TextIndexer.kDefaultTokenizer,
  });

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

  @override
  final Tokenizer tokenizer;

  /// Implementation of [TextIndexer.updateDictionary].
  ///
  /// Calls the [dictionaryUpdater] callback function.
  @override
  Future<void> updateDictionary(Dictionary values) => dictionaryUpdater(values);

  /// Implementation of [TextIndexer.loadTermPostings].
  ///
  /// Calls the [postingsLoader] callback function.
  @override
  Future<Postings> loadTermPostings(Iterable<String> terms) =>
      postingsLoader(terms);

  /// Implementation of [TextIndexer.upsertTermPostings].
  ///
  /// Calls the [postingsUpdater] callback function.
  @override
  Future<void> upsertTermPostings(Postings values) => postingsUpdater(values);

  /// Implementation of [TextIndexer.loadTerms].
  ///
  /// Calls the [termsLoader] callback function.
  @override
  Future<Dictionary> loadTerms(Iterable<String> terms) => termsLoader(terms);
}
