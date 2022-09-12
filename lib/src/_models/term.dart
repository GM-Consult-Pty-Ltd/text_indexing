// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/text_indexing.dart';

/// Enumerates the sorting strategy for [Dictionary]'s [DictionaryEntry]s.
enum TermSortStrategy {
  /// Sorts the [DictionaryEntry] collection alphabetically.
  byTerm,

  /// Sorts the [DictionaryEntry] collection by [DictionaryEntry.frequency] in descending order.
  byFrequency
}

/// A [DictionaryEntry] is a unit of entry in the [Dictionary] of an inverted index.
/// It enumerates the following properties:
/// - [term] is the word/term that is indexed; and
/// - [frequency] is the number of documents that contain [term].
class DictionaryEntry {
  //

  /// The word/term that is indexed.
  ///
  /// The [term] must not be an empty String.
  ///
  /// The [term] must only occur once in the [Dictionary].
  final String term;

  /// The number number of documents that contain [term].
  final int frequency;

  /// Serializes the [DictionaryEntry] to a MapEntry<String, int> for direct insertion
  /// into a [Dictionary].
  MapEntry<String, int> toMapEntry() => MapEntry(term, frequency);

  /// Instantiates a const [DictionaryEntry] instance:
  /// - [term] is the word/term that is indexed; and
  /// - [frequency] is the number of documents that contain [term].
  const DictionaryEntry(this.term, this.frequency);

  /// Factory constructor that instantiates a [DictionaryEntry] instance from the
  /// [value] map entry:
  /// - the [MapEntry.key] is the word/term that is indexed; and
  /// - the [MapEntry.value] is the number of documents that reference the term.
  factory DictionaryEntry.fromEntry(MapEntry<String, int> value) =>
      DictionaryEntry(value.key, value.value);

  /// Returns a copy of the [DictionaryEntry] instance with the [DictionaryEntry.frequency] set to
  /// [frequency].
  DictionaryEntry setFrequency(int frequency) =>
      DictionaryEntry(term, frequency);

  /// Returns a copy of the [DictionaryEntry] instance with the [DictionaryEntry.frequency]
  /// incremented by 1.
  DictionaryEntry incrementFrequency() => setFrequency(frequency + 1);
}

/// Extension methods on a collection of [DictionaryEntry]s.
extension TermsCollectionExtension on Iterable<DictionaryEntry> {
//

  /// Sorts the collection of [DictionaryEntry]s according to [sortBy] value:
  /// - [TermSortStrategy.byTerm] sorts the [DictionaryEntry]s alphabetically (default); or
  /// - [TermSortStrategy.byFrequency] sorts the [DictionaryEntry]s by [DictionaryEntry.frequency] in
  ///   descending order.
  List<DictionaryEntry> sort(
          [TermSortStrategy sortBy = TermSortStrategy.byTerm]) =>
      sortBy == TermSortStrategy.byTerm ? sortByTerm() : sortByFrequency();

  /// Sorts the collection of [DictionaryEntry]s by [DictionaryEntry.frequency] in descending order.
  List<DictionaryEntry> sortByFrequency() {
    final terms = List<DictionaryEntry>.from(this);
    terms.sort((a, b) => b.frequency.compareTo(a.frequency));
    return terms;
  }

  /// Sorts the collection of [DictionaryEntry]s alphabetically.
  List<DictionaryEntry> sortByTerm() {
    final terms = List<DictionaryEntry>.from(this);
    terms.sort((a, b) => a.term.compareTo(b.term));
    return terms;
  }
}
