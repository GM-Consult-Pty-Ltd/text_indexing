// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/text_indexing.dart';

/// Enumerates the sorting strategy for [Dictionary]'s [DictionaryEntry]s.
enum TermSortStrategy {
  //

  /// Sorts the [DictionaryEntry] collection alphabetically.
  byTerm,

  /// Sorts the [DictionaryEntry] collection by [Ft] in
  /// descending order.
  byFrequency
}

/// An alias for [int], used to denote the frequency of a [Term] in an index or
/// indexed object (the term frequency).
typedef Ft = int;

/// Defines a term dictionary used in an inverted index.
///
/// The [Dictionary] is a hashmap of [DictionaryEntry]s with the vocabulary as
/// key and the document frequency as the values.
///
/// A [Dictionary] can be an asynchronous data source or an in-memory hashmap.
typedef Dictionary = Map<Term, Ft>;

/// A [DictionaryEntry] is an entry in a [Dictionary].
///
/// Alias for MapEntry<Term, Ft>.
typedef DictionaryEntry = MapEntry<Term, Ft>;

/// Asynchronously retrieves a [Dictionary] subset for a collection of
/// [terms] from a [Dictionary] data source, usually persisted storage.
typedef DictionaryLoader = Future<Dictionary> Function(Iterable<Term> terms);

/// A callback that passes [values] for persisting to a [Dictionary].
///
/// Parameter [values] is a subset of a [Dictionary] containing new or changed
/// [DictionaryEntry] instances.
typedef DictionaryUpdater = Future<void> Function(Dictionary values);

/// A [DictionaryEntry] is a unit of entry in the [Dictionary] of an inverted
/// index.
/// It enumerates the following property getters:
/// - [term] is the word/term that is indexed; and
/// - [frequency] is the number of documents that contain [term].
extension DictionaryEntryExtension on DictionaryEntry {
  //

  /// The word/term that is indexed.
  ///
  /// The [term] must not be an empty String.
  ///
  /// The [term] must only occur once in the [Dictionary].
  Term get term => key;

  /// The number number of documents that contain [term].
  Ft get frequency => value;

  /// Returns a copy of the [DictionaryEntry] instance with the [Ft] set to
  /// [frequency].
  DictionaryEntry setFrequency(Ft frequency) =>
      DictionaryEntry(term, frequency);

  /// Returns a copy of the [DictionaryEntry] instance with the [Ft]
  /// incremented by 1.
  DictionaryEntry incrementFrequency() => setFrequency(frequency + 1);
}

/// Extension methods on [Dictionary.entries].
extension DictionaryEntryCollectionExtension on Iterable<DictionaryEntry> {
//

  /// Sorts the collection of [DictionaryEntry]s according to [sortBy] value:
  /// - [TermSortStrategy.byTerm] sorts the [DictionaryEntry]s alphabetically (default); or
  /// - [TermSortStrategy.byFrequency] sorts the [DictionaryEntry]s by [Ft] in
  ///   descending order.
  List<DictionaryEntry> sort(
          [TermSortStrategy sortBy = TermSortStrategy.byTerm]) =>
      sortBy == TermSortStrategy.byTerm ? sortByTerm() : sortByFrequency();

  /// Sorts the collection of [DictionaryEntry]s by [Ft] in descending order.
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

/// Extensions on [DictionaryEntry].
extension DictionaryExtensions on Dictionary {
  //

  /// Returns a list of [DictionaryEntry]s from the [entries] in the [Dictionary].
  ///
  /// Sorts the terms according to [sortBy] value:
  /// - [TermSortStrategy.byTerm] sorts the [DictionaryEntry]s alphabetically (default); or
  /// - [TermSortStrategy.byFrequency] sorts the [DictionaryEntry]s by [Ft] in
  ///   descending order.
  List<DictionaryEntry> toList(
          [TermSortStrategy sortBy = TermSortStrategy.byTerm]) =>
      entries.toList();

  /// Returns the dictionary terms (keys) as an ordered list,
  /// sorted alphabetically.
  List<String> get terms {
    final terms = keys.toList();
    terms.sort((a, b) => a.compareTo(b));
    return terms;
  }

  /// Inserts or replaces the [value] in the [Dictionary].
  void addEntry(DictionaryEntry value) => this[value.term] = value.frequency;

  /// Returns the mapped value for the [term] key from the [Dictionary].
  ///
  /// Returns 0 if the [term] key does not exist in the [Dictionary].
  Ft getFrequency(Term term) => this[term] ?? 0;

  /// Returns a [DictionaryEntry] with:
  /// - key set to [term]; and
  /// - the value set to [frequency].
  DictionaryEntry setFrequency(Term term, Ft frequency) {
    this[term] = frequency;
    return DictionaryEntry(term, frequency);
  }

  /// Returns a DictionaryEntry with the key set to [term].
  ///
  /// If the [term] key exists in the [Dictionary], it's mapped value is
  /// incremented by 1.
  ///
  /// If the [term] key does not exist in the [Dictionary], an entry is created
  /// and its value set to 1.
  DictionaryEntry incrementFrequency(String term) =>
      setFrequency(term, getFrequency(term) + 1);
}
