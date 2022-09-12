// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/text_indexing.dart';

/// Extensions on [DictionaryEntry].
extension TermDictionaryExtensions on Dictionary {
  //

  /// Returns a list of [DictionaryEntry]s from the [entries] in the [Dictionary].
  ///
  /// Sorts the terms according to [sortBy] value:
  /// - [TermSortStrategy.byTerm] sorts the [DictionaryEntry]s alphabetically (default); or
  /// - [TermSortStrategy.byFrequency] sorts the [DictionaryEntry]s by [DictionaryEntry.frequency] in
  ///   descending order.
  List<DictionaryEntry> toList(
          [TermSortStrategy sortBy = TermSortStrategy.byTerm]) =>
      entries.map((e) => DictionaryEntry.fromEntry(e)).sort(sortBy);

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
  int getFrequency(String term) => this[term] ?? 0;

  /// Returns a [DictionaryEntry] with:
  /// - key set to [term]; and
  /// - the value set to [frequency].
  DictionaryEntry setFrequency(String term, int frequency) {
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
