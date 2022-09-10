// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/text_indexing.dart';

/// A [Term] is a unit of entry in the [Dictionary] of an inverted index.
/// It enumerates the following properties:
/// - [term] is the word/term that is indexed; and
/// - [frequency] is the number of documents that contain [term].
class Term {
  //

  /// The word/term that is indexed.
  ///
  /// The [term] must not be an empty String.
  ///
  /// The [term] must only occur once in the [Dictionary].
  final String term;

  /// The number of occurrences in the associated [Postings] list.
  final int frequency;

  /// Instantiates a const [Term] instance:
  /// - [term] is the word/term that is indexed; and
  /// - [frequency] is the number of occurrences in the associated [Postings] list.
  const Term(this.term, this.frequency);

  /// Factory constructor that instantiates a [Term] instance from the
  /// [value] map entry:
  /// - the [MapEntry.key] is the word/term that is indexed; and
  /// - the [MapEntry.value] is the number of documents that reference the term.
  factory Term.fromEntry(MapEntry<String, int> value) =>
      Term(value.key, value.value);

  /// Returns a copy of the [Term] instance with the [Term.frequency] set to
  /// [frequency].
  Term setFrequency(int frequency) => Term(term, frequency);

  /// Returns a copy of the [Term] instance with the [Term.frequency]
  /// incremented by 1.
  Term incrementFrequency() => setFrequency(frequency + 1);
}
