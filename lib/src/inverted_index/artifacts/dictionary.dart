// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'dart:math';
import 'package:text_indexing/src/_index.dart';

/// A [DftMapEntry] is a unit of entry in the [DftMap] of an inverted
/// index.
/// It enumerates the following property getters:
/// - [term] is the word/term that is indexed; and
/// - [dFt] is the number of documents that contain [term].
extension DictionaryEntryExtension on DftMapEntry {
  //

  /// The word/term that is indexed.
  ///
  /// The [term] must not be an empty String.
  ///
  /// The [term] must only occur once in the [DftMap].
  Term get term => key;

  /// The number of documents that contain [term].
  Ft get dFt => value;

  /// Returns a copy of the [DftMapEntry] instance with the [Ft] set to
  /// [frequency].
  DftMapEntry setFrequency(Ft frequency) => DftMapEntry(term, frequency);

  /// Returns a copy of the [DftMapEntry] instance with the [Ft]
  /// incremented by 1.
  DftMapEntry incrementFrequency() => setFrequency(dFt + 1);
}

/// A [DftMapEntry] is a unit of entry in the [DftMap] of an inverted
/// index.
/// It enumerates the following property getters:
/// - [term] is the word/term that is indexed; and
/// - [iDFt] is the number of documents that contain [term].
extension IDftDictionaryEntryExtension on MapEntry<String, IdFt> {
  //

  /// The word/term that is indexed.
  ///
  /// The [term] must not be an empty String.
  ///
  /// The [term] must only occur once in the [DftMap].
  Term get term => key;

  /// The inverse document frequency of [term] in the `corpus`.
  IdFt get iDFt => value;
}

/// Extension methods on [DftMap.entries].
extension DictionaryEntryCollectionExtension on Iterable<DftMapEntry> {
//

  /// Sorts the collection of [DftMapEntry]s according to [sortBy] value:
  /// - [TermSortStrategy.byTerm] sorts the [DftMapEntry]s alphabetically (default); or
  /// - [TermSortStrategy.byFrequency] sorts the [DftMapEntry]s by [Ft] in
  ///   descending order.
  List<DftMapEntry> sort([TermSortStrategy sortBy = TermSortStrategy.byTerm]) =>
      sortBy == TermSortStrategy.byTerm ? sortByTerm() : sortByFrequency();

  /// Sorts the collection of [DftMapEntry]s by [Ft] in descending order.
  List<DftMapEntry> sortByFrequency() {
    final terms = List<DftMapEntry>.from(this);
    terms.sort((a, b) => b.dFt.compareTo(a.dFt));
    return terms;
  }

  /// Sorts the collection of [DftMapEntry]s alphabetically.
  List<DftMapEntry> sortByTerm() {
    final terms = List<DftMapEntry>.from(this);
    terms.sort((a, b) => a.term.compareTo(b.term));
    return terms;
  }
}

/// Extensions on [IdFtIndex].
extension IdFtIndexExtensions on Map<String, double> {
  //

  /// Returns a list of [DftMapEntry]s from the [entries] in the [DftMap].
  ///
  /// Sorts the terms according to [sortBy] value:
  /// - [TermSortStrategy.byTerm] sorts the [DftMapEntry]s alphabetically (default); or
  /// - [TermSortStrategy.byFrequency] sorts the [DftMapEntry]s by [Ft] in
  ///   descending order.
  List<MapEntry<String, double>> toList(
      [TermSortStrategy sortBy = TermSortStrategy.byTerm]) {
    final list = entries.toList();
    switch (sortBy) {
      case TermSortStrategy.byTerm:
        list.sort(((a, b) => a.key.compareTo(b.key)));
        break;
      case TermSortStrategy.byFrequency:
        list.sort(((a, b) => b.value.compareTo(a.value)));
        break;
    }
    return list;
  }

  /// Returns the dictionary terms (keys) as an ordered list,
  /// sorted alphabetically.
  List<String> get terms {
    final terms = keys.toList();
    terms.sort((a, b) => a.compareTo(b));
    return terms;
  }
}

/// Extensions on [DftMapEntry].
extension DictionaryExtensions on DftMap {
//

  /// Returns the inverse document frequency of the [term] for a corpus of size
  /// [n].
  double idFt(String term, int n) => log(n / getFrequency(term));

  /// Returns a hashmap of term to Tf-idf weight for a document.
  Map<String, double> tfIdfMap(Map<String, num> termFrequencies, int n) =>
      termFrequencies.map((term, tF) => MapEntry(term, tF * idFt(term, n)));

  /// Filters the [DftMap] by terms.
  ///
  /// Returns a subset of the [DftMap] instance that only contains
  /// entires with a key in the [terms] collection.
  DftMap getEntries(Iterable<Term> terms) {
    final DftMap retVal = {}
      ..addEntries(entries.where((element) => terms.contains(element.key)));
    return retVal;
  }

  /// Returns the inverse document frequency of the [term] for a corpus of size
  /// [n].
  double getIdFt(String term, int n) => log(n / getFrequency(term));

  /// Returns a hashmap of term to inverse document frequency of the term.
  ///
  /// The parameter [collectionSize] is the total number of documents in the
  /// collection.
  Map<String, double> getIdFtMap(int collectionSize) =>
      map((key, value) => MapEntry(key, log(collectionSize / value)));

  /// Returns a list of [DftMapEntry]s from the [entries] in the [DftMap].
  ///
  /// Sorts the terms according to [sortBy] value:
  /// - [TermSortStrategy.byTerm] sorts the [DftMapEntry]s alphabetically (default); or
  /// - [TermSortStrategy.byFrequency] sorts the [DftMapEntry]s by [Ft] in
  ///   descending order.
  List<DftMapEntry> toList(
      [TermSortStrategy sortBy = TermSortStrategy.byTerm]) {
    final list = entries.toList();
    switch (sortBy) {
      case TermSortStrategy.byTerm:
        list.sort(((a, b) => a.term.compareTo(b.term)));
        break;
      case TermSortStrategy.byFrequency:
        list.sort(((a, b) => b.dFt.compareTo(a.dFt)));
        break;
    }
    return list;
  }

  /// Returns the dictionary terms (keys) as an ordered list,
  /// sorted alphabetically.
  List<String> get terms {
    final terms = keys.toList();
    terms.sort((a, b) => a.compareTo(b));
    return terms;
  }

  /// Inserts or replaces the [value] in the [DftMap].
  void addEntry(DftMapEntry value) => this[value.term] = value.dFt;

  /// Returns the mapped value for the [term] key from the [DftMap].
  ///
  /// Returns 0 if the [term] key does not exist in the [DftMap].
  Ft getFrequency(Term term) => this[term] ?? 0;

  /// Returns a [DftMapEntry] with:
  /// - key set to [term]; and
  /// - the value set to [frequency].
  DftMapEntry setFrequency(Term term, Ft frequency) {
    this[term] = frequency;
    return DftMapEntry(term, frequency);
  }

  /// Returns a DftMapEntry with the key set to [term].
  ///
  /// If the [term] key exists in the [DftMap], it's mapped value is
  /// incremented by 1.
  ///
  /// If the [term] key does not exist in the [DftMap], an entry is created
  /// and its value set to 1.
  DftMapEntry incrementFrequency(String term) =>
      setFrequency(term, getFrequency(term) + 1);
}
