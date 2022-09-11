// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

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
