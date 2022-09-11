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
    TermDictionary? dictionary,
    this.tokenizer = Indexer.kDefaultTokenizer,
    PostingsMap? postings,
  })  : postings = postings ?? {},
        dictionary = dictionary ?? {};

  /// The in-memory term dictionary for the indexer
  final TermDictionary dictionary;

  /// The in-memory postings hashmap for the indexer.
  final PostingsMap postings;

  @override
  final Tokenizer tokenizer;

  @override
  Future<PostingsMap> loadTermPostings(Iterable<String> terms) async {
    final PostingsMap retVal = {};
    for (final term in terms) {
      final entry = postings[term];
      if (entry != null) {
        retVal[term] = entry;
      }
    }
    return retVal;
  }

  @override
  Future<void> updateDictionary(TermDictionary terms) async {
    return;
  }

  @override
  Future<void> upsertTermPostings(PostingsMap postings) async {
    this.postings.addAll(postings);
  }

  @override
  Future<TermDictionary> loadTerms(Iterable<String> terms) async {
    final TermDictionary retVal = {};
    for (final term in terms) {
      final entry = dictionary[term];
      if (entry != null) {
        retVal[term] = entry;
      }
    }
    return retVal;
  }
}
