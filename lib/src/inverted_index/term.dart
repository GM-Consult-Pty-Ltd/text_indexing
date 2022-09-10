// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/text_indexing.dart';

/// Enumerates the sorting strategy for [TermDictionary]'s [Term]s.
enum TermSortStrategy {
  /// Sorts the [Term] collection alphabetically.
  byTerm,

  /// Sorts the [Term] collection by [Term.frequency] in descending order.
  byFrequency
}

/// A [Term] is a unit of entry in the [TermDictionary] of an inverted index.
/// It enumerates the following properties:
/// - [term] is the word/term that is indexed; and
/// - [frequency] is the number of documents that contain [term].
class Term {
  //

  /// The word/term that is indexed.
  ///
  /// The [term] must not be an empty String.
  ///
  /// The [term] must only occur once in the [TermDictionary].
  final String term;

  /// The number number of documents that contain [term].
  final int frequency;

  /// Serializes the [Term] to a MapEntry<String, int> for direct insertion
  /// into a [TermDictionary].
  MapEntry<String, int> toMapEntry() => MapEntry(term, frequency);

  /// Instantiates a const [Term] instance:
  /// - [term] is the word/term that is indexed; and
  /// - [frequency] is the number of documents that contain [term].
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

/// Extension methods on a collection of [Term]s.
extension TermsCollectionExtension on Iterable<Term> {
//

  /// Sorts the collection of [Term]s according to [sortBy] value:
  /// - [TermSortStrategy.byTerm] sorts the [Term]s alphabetically (default); or
  /// - [TermSortStrategy.byFrequency] sorts the [Term]s by [Term.frequency] in
  ///   descending order.
  List<Term> sort([TermSortStrategy sortBy = TermSortStrategy.byTerm]) =>
      sortBy == TermSortStrategy.byTerm ? sortByTerm() : sortByFrequency();

  /// Sorts the collection of [Term]s by [Term.frequency] in descending order.
  List<Term> sortByFrequency() {
    final terms = List<Term>.from(this);
    terms.sort((a, b) => b.frequency.compareTo(a.frequency));
    return terms;
  }

  /// Sorts the collection of [Term]s alphabetically.
  List<Term> sortByTerm() {
    final terms = List<Term>.from(this);
    terms.sort((a, b) => a.term.compareTo(b.term));
    return terms;
  }
}
