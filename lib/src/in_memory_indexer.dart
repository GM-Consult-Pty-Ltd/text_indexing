// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:rxdart/rxdart.dart';
import 'package:text_indexing/text_indexing.dart';

/// Implementation of [TextIndexerBase] that constructs and maintains an
/// in-memory inverted index
class InMemoryIndexer extends TextIndexerBase {
  //

  /// Initializes a [InMemoryIndexer] instance:
  /// - pass a [analyzer] text analyser that extracts tokens from text;
  /// - pass an in-memory [dictionary] instance, otherwise an empty
  ///   [Dictionary] will be initialized.
  /// - pass an in-memory [postings] instance, otherwise an empty [Postings]
  ///   will be initialized.
  InMemoryIndexer(
      {required ITextAnalyzer analyzer,
      Dictionary? dictionary,
      Postings? postings})
      : index = InMemoryIndex(
            dictionary: dictionary ?? {},
            postings: postings ?? {},
            analyzer: analyzer);

  @override
  final InMemoryIndex index;

  @override
  final controller = BehaviorSubject<Postings>();
}

/// An implementation class for the [InMemoryIndexer], implements
/// [InvertedPositionalZoneIndex] interface:
/// - [analyzer] is the [ITextAnalyzer] used to tokenize text for the index;
/// - [dictionary] is the in-memory term dictionary for the indexer. Pass a
///   [dictionary] instance at instantiation, otherwise an empty [Dictionary]
///   will be initialized; and
/// - [postings] is the in-memory postings hashmap for the indexer. Pass a
///   [postings] instance at instantiation, otherwise an empty [Postings]
///   will be initialized.
class InMemoryIndex implements InvertedPositionalZoneIndex {
  //
  /// The in-memory term dictionary for the indexer.
  final Dictionary dictionary;

  /// The in-memory postings hashmap for the indexer.
  final Postings postings;

  /// Instantiates a [InMemoryIndex] instance:
  /// - [analyzer] is the [ITextAnalyzer] used to tokenize text for the index;
  /// - [dictionary] is the in-memory term dictionary for the indexer. Pass a
  ///   [dictionary] instance at instantiation, otherwise an empty [Dictionary]
  ///   will be initialized; and
  /// - [postings] is the in-memory postings hashmap for the indexer. Pass a
  ///   [postings] instance at instantiation, otherwise an empty [Postings]
  ///   will be initialized.
  const InMemoryIndex(
      {required this.dictionary,
      required this.postings,
      required this.analyzer});

  @override
  Future<Dictionary> getDictionary([Iterable<Term>? terms]) async {
    if (terms == null) return dictionary;
    final Dictionary retVal = {};
    for (final term in terms) {
      final entry = dictionary[term];
      if (entry != null) {
        retVal[term] = entry;
      }
    }
    return retVal;
  }

  @override
  final ITextAnalyzer analyzer;

  @override
  Future<Postings> getPostings(Iterable<Term> terms) async {
    final Postings retVal = {};
    for (final term in terms) {
      final entry = postings[term];
      if (entry != null) {
        retVal[term] = entry;
      }
    }
    return retVal;
  }

  @override
  Future<void> upsertDictionary(Dictionary values) async =>
      dictionary.addAll(values);

  @override
  Future<void> upsertPostings(Postings values) async => postings.addAll(values);
}
