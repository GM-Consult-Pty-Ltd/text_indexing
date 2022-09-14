// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/text_indexing.dart';

/// The [Document] object-model enumerates the properties of a document and
/// its indexed terms in an inverted positional index.
///
/// The [Document] properties are stored in the [Postings] of the index,
/// distributed over the vocabulary terms.  [Document]s are extracted from
/// the [Postings] by filtering the [Postings] entries for [PostingsMap]
/// elements with the same identifier [docId] as the document.
abstract class Document {
  //

  /// Instantiates a const [Document] instance.
  const Document();

  /// The document's unique identifier in the corpus.
  String get docId;

  /// An alphabetically ordered list of the terms in the document as they
  /// appear in the index.
  List<String> get terms;

  /// A hash of terms to the number of times each term occurs in the document.
  Map<String, int> get termFrequencies;

  /// A hash of terms to a hash of the fields of the document in which they
  /// appear and a list of term positions in that field.
  Map<String, Map<String, List<int>>> get termFieldPostings;

  //
}
