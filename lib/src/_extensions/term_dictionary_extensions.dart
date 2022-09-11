// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/text_indexing.dart';

/// Extensions on [Term].
extension TermDictionaryExtensions on TermDictionary {
  //

  /// Returns a list of [Term]s from the [entries] in the [TermDictionary].
  ///
  /// Sorts the terms according to [sortBy] value:
  /// - [TermSortStrategy.byTerm] sorts the [Term]s alphabetically (default); or
  /// - [TermSortStrategy.byFrequency] sorts the [Term]s by [Term.frequency] in
  ///   descending order.
  List<Term> toList([TermSortStrategy sortBy = TermSortStrategy.byTerm]) =>
      entries.map((e) => Term.fromEntry(e)).sort(sortBy);

  /// Returns the dictionary terms (keys) as an ordered list,
  /// sorted alphabetically.
  List<String> get terms {
    final terms = keys.toList();
    terms.sort((a, b) => a.compareTo(b));
    return terms;
  }

  /// Inserts or replaces the [value] in the [TermDictionary].
  void addEntry(Term value) => this[value.term] = value.frequency;

  /// Returns the mapped value for the [term] key from the [TermDictionary].
  ///
  /// Returns 0 if the [term] key does not exist in the [TermDictionary].
  int getFrequency(String term) => this[term] ?? 0;

  /// Returns a [Term] with:
  /// - key set to [term]; and
  /// - the value set to [frequency].
  Term setFrequency(String term, int frequency) {
    this[term] = frequency;
    return Term(term, frequency);
  }

  /// Returns a Term with the key set to [term].
  ///
  /// If the [term] key exists in the [TermDictionary], it's mapped value is
  /// incremented by 1.
  ///
  /// If the [term] key does not exist in the [TermDictionary], an entry is created
  /// and its value set to 1.
  Term incrementFrequency(String term) =>
      setFrequency(term, getFrequency(term) + 1);
}
