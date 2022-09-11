// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

// import 'package:meta/meta.dart';
import 'package:text_analysis/text_analysis.dart';
import 'package:text_indexing/text_indexing.dart';

/// Maintains an in-memory term dictionary index and asynchronously updates
/// a [TermDictionary] and [PostingsMap] whenever a document is indexed:
/// - [tokenizer] parses documents to tokens;
/// - [termsLoader] synchronously retrieves a [TermDictionary] subset for a
///   collection of terms from a data source;
/// - [dictionaryUpdater] is callback that passes a [TermDictionary] subset
///    for persisting to a datastore;
/// - [postingsLoader] asynchronously retrieves a [PostingsMap] subset for a
///   collection of terms from a data source;
/// - [postingsUpdater] passes a [PostingsMap] subset for persisting to a
///   datastore;
///
/// Provides the [index] method to allow documents to be indexed one-by-one:
/// - a [TermDictionary] is asynchronously updated by calling the
///   [dictionaryUpdater] callback with the subset of te dictionary that is new
///   or changed; and
/// - a [PostingsMap] is asynchronously updated by calling the [postingsUpdater]
///   callback, passing the collection of new/updated postings.
class PersistedIndexer extends Indexer {
  //

  /// Instantiates a [PersistedIndexer] instance:
  /// - [tokenizer] parses documents to tokens;
  /// - [termsLoader] synchronously retrieves a [TermDictionary] subset for a
  ///   collection of terms from a data source;
  /// - [dictionaryUpdater] is callback that passes a [TermDictionary] subset
  ///    for persisting to a datastore;
  /// - [postingsLoader] asynchronously retrieves a [PostingsMap] subset for a
  ///   collection of terms from a data source;
  /// - [postingsUpdater] passes a [PostingsMap] subset for persisting to a
  ///   datastore;
  PersistedIndexer(
      {required this.tokenizer,
      required this.termsLoader,
      required this.dictionaryUpdater,
      required this.postingsLoader,
      required this.postingsUpdater});

  /// Asynchronously retrieves a [TermDictionary] subset for a collection of
  /// terms from a [TermDictionary] data source, usually persisted storage.
  final DictionaryLoader termsLoader;

  /// A callback that passes a [TermDictionary] subset for persisting to
  /// the [TermDictionary] datastore.
  final DictionaryUpdater dictionaryUpdater;

  /// Asynchronously retrieves a [PostingsMap] subset for a collection of
  /// terms from a [PostingsMap] data source, usually persisted storage.
  final PostingsLoader postingsLoader;

  /// A callback that passes a [PostingsMap] subset for persisting to the
  /// [PostingsMap] datastore.
  final PostingsUpdater postingsUpdater;

  @override
  final Tokenizer tokenizer;

  @override
  Future<void> updateDictionary(TermDictionary terms) =>
      dictionaryUpdater(terms);

  @override
  Future<PostingsMap> loadTermPostings(Iterable<String> terms) =>
      postingsLoader(terms);

  @override
  Future<void> upsertTermPostings(PostingsMap postings) =>
      postingsUpdater(postings);

  @override
  Future<TermDictionary> loadTerms(Iterable<String> terms) =>
      termsLoader(terms);
}
