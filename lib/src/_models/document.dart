// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/text_indexing.dart';

/// The [Document] object-model enumerates the properties of a document and
/// its indexed terms in an inverted positional index.
///
/// The [Document] properties are stored in the [Postings] of the index,
/// distributed over the vocabulary terms.  [Document]s are extracted from
/// the [Postings] by filtering the [Postings] entries for [DocumentPostingsEntry]
/// elements with the same identifier [docId] as the document.
abstract class Document {
  //

  /// Instantiates a const [Document] instance.
  const Document();

  /// The document's unique identifier ([DocId]) in the corpus.
  DocId get docId;

  /// An alphabetically ordered list of the [Term]s in the document.
  List<Term> get terms;

  /// A hashmap of [Term]s to the number of times ([Ft]) each [Term] occurs in
  /// the document.
  Map<Term, Ft> get termFrequencies;

  /// Returns the frequency of [term] in the document.
  Ft tF(Term term);

  /// A hashmap of [Term]s to [FieldPostings] for the document.
  Map<FieldName, FieldPostings> get termFieldPostings;

  //
}
