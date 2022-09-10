// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/text_indexing.dart';

/// Defines a collection of postings for a positional inverted index.
///
/// [PostingsMap] is a hashmap of [Term]s where:
/// - the key is the word/term that is indexed; and
/// - the value is a hashmap of document ids to a [Set] of positions of the term
///   in each document.
typedef PostingsMap = Map<String, Map<String, Set<int>>>;

/// The [PostingsMapEntry] class enumerates the properties of entry in a
/// [PostingsMap] as part of an inverted index of a dataset:
/// - [term] is the word/term that is indexed; and
/// - [postings] is a hashmap of the [DocumentPostings] for [term].
class PostingsMapEntry {
  //

  /// The word/term that is indexed.
  ///
  /// The [term] must not be an empty String.
  ///
  /// The [term] must only occur once in the [Dictionary].
  final String term;

  /// A hashmap of the [DocumentPostings] for [term] where:
  /// - the [postings].key is the id of the document;
  /// - the [postings].value is the postings in the document of the [term].
  final Map<String, DocumentPostings> postings;

  /// Instantiates a const [PostingsMapEntry] instance:
  /// - [term] is the word/term that is indexed; and
  /// - [postings] is a hashmap of the [DocumentPostings] for [term].
  const PostingsMapEntry(this.term, this.postings);

  /// Factory constructor that instantiates a [PostingsMapEntry] instance from
  /// a [PostingsMap] map entry.
  factory PostingsMapEntry.fromEntry(
      MapEntry<String, Map<String, Set<int>>> entry) {
    final term = entry.key;
    final postings = entry.value.map((key, value) =>
        MapEntry(key, DocumentPostings.fromEntry(term, MapEntry(key, value))));

    return PostingsMapEntry(term, postings);
  }
}
