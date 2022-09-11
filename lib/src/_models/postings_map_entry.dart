// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/text_indexing.dart';

/// The [PostingsMapEntry] class enumerates the properties of an entry in a
/// [PostingsMap] collection:
/// - [term] is the word/term that is indexed; and
/// - [postings] is a hashmap of the [TermPositions] for [term].
class PostingsMapEntry {
  //

  /// Serializes the [PostingsMapEntry] to a MapEntry for direct insertion in
  /// a [PostingsMap].
  MapEntry<String, Map<String, List<int>>> toMapEntry() => MapEntry(
      term,
      postings
          .map((key, value) => MapEntry(key, List<int>.from(value.positions))));

  /// The word/term that is indexed.
  ///
  /// The [term] must not be an empty String.
  ///
  /// The [term] must only occur once in the [TermDictionary].
  final String term;

  /// A hashmap of the [TermPositions] for [term] where:
  /// - the [postings].key is the id of the document;
  /// - the [postings].value is the postings in the document of the [term].
  final Map<String, TermPositions> postings;

  /// Instantiates a const [PostingsMapEntry] instance:
  /// - [term] is the word/term that is indexed; and
  /// - [postings] is a hashmap of the [TermPositions] for [term].
  const PostingsMapEntry(this.term, this.postings);

  /// Factory constructor that instantiates a [PostingsMapEntry] instance from
  /// a [PostingsMap] map entry.
  factory PostingsMapEntry.fromEntry(
      MapEntry<String, Map<String, List<int>>> entry) {
    final term = entry.key;
    final postings = entry.value.map((key, value) =>
        MapEntry(key, TermPositions.fromEntry(term, MapEntry(key, value))));

    return PostingsMapEntry(term, postings);
  }
}
