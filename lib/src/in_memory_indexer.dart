// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

// ignore_for_file: deprecated_member_use_from_same_package

import 'package:rxdart/rxdart.dart';
import 'package:text_indexing/text_indexing.dart';

/// Implementation of [TextIndexerBase] that constructs and maintains an
/// in-memory inverted index
class InMemoryIndexer extends TextIndexerBase {
  //

  /// Initializes a [InMemoryIndexer] instance:
  /// - pass a [tokenizer] to parse text to tokens,
  ///   or use the default [TextIndexer.kDefaultTokenizer];
  /// - pass a [jsonTokenizer] used to parse JSON documents to tokens,
  ///   or use the default [TextIndexer.kDefaultJsonTokenizer];
  /// - pass an in-memory [dictionary] instance, otherwise an empty
  ///   [Dictionary] will be initialized.
  /// - pass an in-memory [postings] instance, otherwise an empty [Postings]
  ///   will be initialized.
  InMemoryIndexer(
      {Dictionary? dictionary,
      Postings? postings,
      this.tokenizer = TextIndexer.kDefaultTokenizer,
      this.jsonTokenizer = TextIndexer.kDefaultJsonTokenizer})
      : index = InMemoryIndex(dictionary ?? {}, postings ?? {});

  @override
  final InvertedPositionalZoneIndex index;

  @override
  final Tokenizer tokenizer;

  @override
  final JsonTokenizer jsonTokenizer;

  @override
  final controller = BehaviorSubject<Postings>();
}

/// An implementation class for the [InMemoryIndexer], implements
/// [InvertedPositionalZoneIndex] interface:
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
  /// - [dictionary] is the in-memory term dictionary for the indexer. Pass a
  ///   [dictionary] instance at instantiation, otherwise an empty [Dictionary]
  ///   will be initialized; and
  /// - [postings] is the in-memory postings hashmap for the indexer. Pass a
  ///   [postings] instance at instantiation, otherwise an empty [Postings]
  ///   will be initialized.
  const InMemoryIndex(this.dictionary, this.postings);

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
