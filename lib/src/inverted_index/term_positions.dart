// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/text_indexing.dart';

/// The [TermPositions] class enumerates the properties of a document
/// posting in a [PostingsMap] as part of an inverted index of a dataset:
/// - [term] is the word/term that is indexed;
/// - [docId] is the document's id value;
/// - [positions] is the zero-based list of word positions of the [term] in
///   the document;
class TermPositions {
  //

  /// The word/term that is indexed.
  ///
  /// The [term] must not be an empty String.
  ///
  /// The [term] must only occur once in the [TermDictionary].
  final String term;

  /// The document's id value.
  ///
  /// Usually the value of the document's primary key field in the dataset.
  final String docId;

  /// The zero-based, ordered list of unique word positions of the [term] in
  /// the document.
  ///
  /// A word position means the index of the word in an array of all the words
  /// in the document.
  ///
  /// Where more than one field is indexed in a document (e.g. a JSON document
  /// with more than one searchable field), the fields should be prioritized
  /// before creating an array of all the terms in the document.
  final List<int> positions;

  /// Instantiates a const [TermPositions] instance:
  /// - [term] is the word/term that is indexed;
  /// - [docId] is the document's id value;
  /// - [positions] is the zero-based list of word positions of the [term] in
  ///   the document;
  const TermPositions(this.term, this.docId, this.positions);

  /// Factory constructor that instantiates a [TermPositions] instance from
  /// the [term] and [entry] where:
  /// - [term] is the word/term associated with the [TermPositions] instance.
  /// - the [entry].key is the word/term that is indexed; and
  /// - the [entry].value is a [List] of zero-based unique word positions of
  ///   [term] in the document.
  factory TermPositions.fromEntry(
      String term, MapEntry<String, List<int>> entry) {
    final docId = entry.key;
    final positions = List<int>.from(entry.value);
    positions.sort((a, b) => a.compareTo(b));
    return TermPositions(term, docId, positions);
  }
}
