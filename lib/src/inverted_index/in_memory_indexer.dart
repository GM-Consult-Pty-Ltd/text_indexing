// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_analysis/text_analysis.dart';
import 'package:text_indexing/src/inverted_index/postings_map.dart';
import 'package:text_indexing/src/inverted_index/term_dictionary.dart';

/// Instantiates an in-memory [TermDictionary] and [PostingsMap].
/// Provides the [index] method to allow documents to be indexed one-by-one.
class InMemoryIndexer {
//

  /// Parses the [docText] into terms using the [tokenizer].
  ///
  /// Indexes the terms to the [dictionary] and the [postings].
  Future<void> index(String docId, String docText) async {
    final terms = (await tokenizer(docText)).map((e) => e.term).toList();
    var position = 0;
    for (var term in terms) {
      dictionary.incrementFrequency(term);
      postings.addTermPosition(term, docId, position);
      position++;
    }
  }

  /// The in-memory term dictionary for the indexer.
  final TermDictionary dictionary = {};

  /// The in-memory postings hashmap for the indexer.
  final PostingsMap postings = {};

  /// The [Tokenizer] used by the indexer to parse documents to tokens.
  Future<List<Token>> tokenizer(String source) async =>
      (await TextAnalyzer().tokenize(source)).tokens;
}
