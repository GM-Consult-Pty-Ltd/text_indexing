// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/text_indexing.dart';

/// The [PostingsMap] class enumerates the properties of a document
/// posting in a [Postings] as part of an inverted index of a dataset:
/// - [term] is the word/term that is indexed;
/// - [docId] is the document's id value;
/// - [fieldPositions] is a hashmap of field names that contain the term to
///   the a zero-based, ordered list of word positions of the [term] in the
///   field.
class PostingsMap {
  //

  /// The word/term that is indexed.
  ///
  /// The [term] must not be an empty String.
  ///
  /// The [term] must only occur once in the [Dictionary].
  final String term;

  /// The document's id value.
  ///
  /// Usually the value of the document's primary key field in the dataset.
  final String docId;

  /// A hashmap of field names that conatin the term to the a zero-based,
  /// ordered list of unique word positions of the [term] in the field.
  ///
  /// A word position means the index of the word in an array of all the words
  /// in the document.
  final Map<String, List<int>> fieldPositions;

  /// Instantiates a const [PostingsMap] instance:
  /// - [term] is the word/term that is indexed;
  /// - [docId] is the document's id value;
  /// - [fieldPositions] is a hashmap of field names that contain the term to
  ///   the a zero-based, ordered list of word positions of the [term] in the
  ///   field.
  const PostingsMap(this.term, this.docId, this.fieldPositions);

  /// Factory constructor that instantiates a [PostingsMap] instance from
  /// the [term] and [entry] where:
  /// - [term] is the word/term associated with the [PostingsMap] instance.
  /// - the [entry].key is the word/term that is indexed; and
  /// - the [entry].value is a [List] of zero-based unique word positions of
  ///   [term] in the document.
  factory PostingsMap.fromEntry(
      String term, MapEntry<String, Map<String, List<int>>> entry) {
    final docId = entry.key;
    final fieldPositions = Map<String, List<int>>.from(entry.value);
    return PostingsMap(term, docId, fieldPositions);
  }
}
