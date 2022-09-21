// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/text_indexing.dart';

/// A hashmap of [KGram] to Set<[Term]>, where the value is the set of unique
/// [Term]s that contain the [KGram] in the key.
///
/// Alias for Map<String, Set<String>>.
typedef KGramIndex = Map<KGram, Set<Term>>;

/// Asynchronously retrieves a [KGramIndex] subset for a collection of
/// [terms] from a [KGramIndex] data source, usually persisted storage.
///
/// Loads the entire [KGramIndex] if [terms] is null.
typedef KGramIndexLoader = Future<KGramIndex> Function([Iterable<Term>? terms]);

/// A callback that passes [values] for persisting to a [KGramIndex].
///
/// Parameter [values] is a subset of a [KGramIndex] containing new or changed
/// entries.
typedef KGramIndexUpdater = Future<void> Function(KGramIndex values);

/// Extension methods on [KGramIndex].
extension KGramIndexExtension on KGramIndex {
  //

  /// Iterates through the [kGrams] and:
  /// - gets the current entry if it exists, or initializes a new entry for the
  ///   k-gram key; and
  /// - adds the [term] to the set of term references for the k-gram key.
  void addTermKGrams(Term term, Iterable<KGram> kGrams) {
    for (final kGram in kGrams.toSet()) {
      final set = this[kGram] ?? {};
      set.add(term);
      this[kGram] = set;
    }
  }
}
