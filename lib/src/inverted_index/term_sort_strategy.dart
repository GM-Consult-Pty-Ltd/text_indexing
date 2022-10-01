// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/src/_index.dart';

/// Enumerates the sorting strategy for [Dictionary]'s [DictionaryEntry]s.
enum TermSortStrategy {
  //

  /// Sorts the [DictionaryEntry] collection alphabetically.
  byTerm,

  /// Sorts the [DictionaryEntry] collection by [Ft] in
  /// descending order.
  byFrequency
}
