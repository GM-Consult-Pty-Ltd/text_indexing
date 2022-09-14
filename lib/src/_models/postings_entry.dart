// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/text_indexing.dart';

/// The [PostingsEntry] class enumerates the properties of an entry in a
/// [Postings] collection:
/// - [term] is the word/term that is indexed; and
/// - [postings] is a hashmap of the [PostingsMap] for [term].
class PostingsEntry {
  //

  /// Serializes the [PostingsEntry] to a MapEntry for direct insertion in
  /// a [Postings].
  MapEntry<String, Map<String, Map<String, List<int>>>> toMapEntry() =>
      MapEntry(
          term,
          postings.map((key, value) => MapEntry(
              key, Map<String, List<int>>.from(value.fieldPositions))));

  /// The word/term that is indexed.
  final String term;

  /// A hashmap of the [PostingsMap] for the [term] where:
  /// - the [postings].key is the id of the document (docId); and
  /// - the [postings].value is the positions in the document's fields of the
  /// [term].
  final Map<String, PostingsMap> postings;

  /// Instantiates a const [PostingsEntry] instance:
  /// - [term] is the word/term that is indexed; and
  /// - [postings] is a hashmap of the [PostingsMap] for [term].
  const PostingsEntry(this.term, this.postings);

  /// Factory constructor that instantiates a [PostingsEntry] instance from
  /// a [Postings] map entry.
  factory PostingsEntry.fromEntry(
      MapEntry<String, Map<String, Map<String, List<int>>>> entry) {
    final term = entry.key;
    final postings = entry.value.map((key, value) =>
        MapEntry(key, PostingsMap.fromEntry(term, MapEntry(key, value))));

    return PostingsEntry(term, postings);
  }
}
