// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/text_indexing.dart';

/// An interface that exposes methods for working with an inverted, positional
/// zoned index on a collection of documents:
/// - [getDictionary] Asynchronously retrieves a [Dictionary] for a collection
///   of [Term]s from a [Dictionary] repository;
/// - [upsertDictionary ] inserts entries into a [Dictionary] repository,
///   overwriting any existing entries;
/// - [getPostings] asynchronously retrieves [Postings] for a collection
///   of [Term]s from a [Postings] repository; and
/// - [upsertPostings] inserts entries into a [Postings] repository,
///   overwriting any existing entries.
abstract class InvertedPositionalZoneIndex {
  //

  /// Asynchronously retrieves a [Dictionary] for the [terms] from a
  /// [Dictionary] repository.
  ///
  /// Loads the entire [Dictionary] if [terms] is null.
  Future<Dictionary> getDictionary([Iterable<Term>? terms]);

  /// Inserts [values] into a [Dictionary] repository, overwriting them if they
  /// already exist.
  Future<void> upsertDictionary(Dictionary values);

  /// Asynchronously retrieves [PostingsEntry] entities for the [terms] from a
  /// [Postings] repository.
  Future<Postings> getPostings(Iterable<Term> terms);

  /// Inserts [values] into a [Postings] repository, overwriting them if they
  /// already exist.
  Future<void> upsertPostings(Postings values);
}
