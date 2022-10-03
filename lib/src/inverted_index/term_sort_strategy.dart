// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/src/_index.dart';

/// Enumerates the sorting strategy for [DftMap]'s [DftMapEntry]s.
enum TermSortStrategy {
  //

  /// Sorts the [DftMapEntry] collection alphabetically.
  byTerm,

  /// Sorts the [DftMapEntry] collection by [Ft] in
  /// descending order.
  byFrequency
}
