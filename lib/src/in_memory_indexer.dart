// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_analysis/text_analysis.dart';
import 'package:text_indexing/text_indexing.dart';

/// Maintains an in-memory inverted index:
/// - [dictionary] is the in-memory term dictionary for the indexer;
/// - [postings] is the in-memory postings hashmap for the indexer; and
/// - [tokenizer] is the [Tokenizer] instance used by the indexer to parse
///   documents to tokens. Defaults to [Indexer.kDefaultTokenizer].
///
/// Provides the [index] method to allow documents to be indexed one-by-one,
/// adding the terms to the [dictionary] and the postings for each document to
/// the [postings].
class InMemoryIndexer extends Indexer {
  //

  /// Initializes a [InMemoryIndexer] instance:
  /// - pass a [tokenizer] used by the indexer to parse  documents to tokens.
  ///   or use the defaults [Indexer.kDefaultTokenizer].
  /// - pass an existing in-memory [dictionary], otherwise one will be
  ///   initialized;
  /// - pass an existing in-memory [postings], otherwise one will be
  ///   initialized.
  InMemoryIndexer({
    this.tokenizer = Indexer.kDefaultTokenizer,
    TermDictionary? dictionary,
    PostingsMap? postings,
  })  : dictionary = dictionary ?? {},
        postings = postings ?? {};

  /// Iterates through the [event] elements:
  /// - adds the postings for each element to the [postings] map; and
  /// - increments the term frequency in [dictionary] if the document did not
  ///   previously have a postings entry in [postings].
  /// Calls super.[emit] to ensure [event] is added to the [postingsStream].
  @override
  void emit(List<TermPositions> event) {
    for (final e in event) {
      final increment = postings.addTermPositions(e.term, e.docId, e.positions);
      if (increment) {
        dictionary.incrementFrequency(e.term);
      }
    }
    super.emit(event);
  }

  /// The in-memory term dictionary for the indexer.
  final TermDictionary dictionary;

  /// The in-memory postings hashmap for the indexer.
  final PostingsMap postings;

  @override
  final Tokenizer tokenizer;
}
