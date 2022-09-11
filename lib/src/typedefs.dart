// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/text_indexing.dart';

/// Defines a term TermDictionary used as an inverted index.
///
/// The [TermDictionary] is a hashmap of [Term]s where:
/// - the key is the word/term that is indexed; and
/// - the value is the number of documents that contain the term.
typedef TermDictionary = Map<String, int>;

/// Defines a collection of postings for a positional inverted index.
///
/// [PostingsMap] is a hashmap of [Term]s where:
/// - the key is the word/term that is indexed; and
/// - the value is a hashmap of document ids to a [List] of positions of the term
///   in each document.
typedef PostingsMap = Map<String, Map<String, List<int>>>;

/// A callback that passes a [TermDictionary] subset for persisting to
/// the [TermDictionary] datastore.
typedef DictionaryUpdater = Future<void> Function(TermDictionary terms);

/// Asynchronously retrieves a [PostingsMap] subset for a collection of
/// [terms] from a [PostingsMap] data source, usually persisted storage.
typedef PostingsLoader = Future<PostingsMap> Function(Iterable<String> terms);

/// Asynchronously retrieves a [TermDictionary] subset for a collection of
/// [terms] from a [TermDictionary] data source, usually persisted storage.
typedef DictionaryLoader = Future<TermDictionary> Function(
    Iterable<String> terms);

/// A callback that passes a [PostingsMap] subset for persisting to the
/// [PostingsMap] datastore.
typedef PostingsUpdater = Future<void> Function(PostingsMap postings);
