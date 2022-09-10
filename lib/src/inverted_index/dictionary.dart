// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/text_indexing.dart';

/// Defines a term dictionary used as an inverted index.
///
/// The [Dictionary] is a hashmap of [Term]s where:
/// - the key is the word/term that is indexed; and
/// - the value is the number of documents that contain the term.
typedef Dictionary = Map<String, int>;

/// Extensions on [Term].
extension DictionaryExtensions on Dictionary {
  //

  /// Returns the mapped value for the [term] key from the [Dictionary].
  ///
  /// Returns 0 if the [term] key does not exist in the [Dictionary].
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
  /// If the [term] key exists in the [Dictionary], it's mapped value is
  /// incremented by 1.
  ///
  /// If the [term] key does not exist in the [Dictionary], an entry is created
  /// and its value set to 1.
  Term incrementFrequency(String term) =>
      setFrequency(term, getFrequency(term) + 1);
}
