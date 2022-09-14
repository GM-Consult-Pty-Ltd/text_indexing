// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/text_indexing.dart';

/// Defines a term dictionary used in an inverted index.
///
/// The [Dictionary] is a hashmap of [DictionaryEntry]s with the vocabulary as
/// key and the document frequency as the values.
///
/// A [Dictionary] can be an asynchronous data source or an in-memory hashmap.
typedef Dictionary = Map<String, int>;

/// Defines a collection of position postings for a positional inverted index.
///
/// [Postings] is a hashmap of [PostingsEntry]s with the vocabulary as key and
/// the postings lists for the linked documents as values.
///
/// A [Postings] can be an asynchronous data source or an in-memory hashmap.
typedef Postings = Map<String, Map<String, Map<String, List<int>>>>;

/// A callback that passes [values] for persisting to a [Dictionary].
///
/// Parameter [values] is a subset of a [Dictionary] containing new or changed
/// [DictionaryEntry] instances.
typedef DictionaryUpdater = Future<void> Function(Dictionary values);

/// Asynchronously retrieves a [Postings] subset for a collection of
/// [terms] from a [Postings] data source, usually persisted storage.
typedef PostingsLoader = Future<Postings> Function(Iterable<String> terms);

/// Asynchronously retrieves a [Dictionary] subset for a collection of
/// [terms] from a [Dictionary] data source, usually persisted storage.
typedef DictionaryLoader = Future<Dictionary> Function(Iterable<String> terms);

/// A callback that [values] for persisting to a [Postings].
///
/// Parameter [values] is a subset of a [Postings] containing new or changed
/// [PostingsEntry] instances.
typedef PostingsUpdater = Future<void> Function(Postings values);
