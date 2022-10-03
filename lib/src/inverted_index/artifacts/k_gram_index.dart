// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/src/_index.dart';

/// Extension methods on [KGramsMap].
extension KGramIndexExtension on KGramsMap {
  //

  /// Returns a set of unique terms by iterating over all the [values] in the
  /// collection and adding the terms to a [Set].
  Set<Term> get terms {
    final kGramTerms = <String>{};
    for (final terms in values) {
      kGramTerms.addAll(terms);
    }
    return kGramTerms;
  }

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
