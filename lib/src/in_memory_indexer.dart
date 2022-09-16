// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

// ignore_for_file: deprecated_member_use_from_same_package

import 'package:text_indexing/text_indexing.dart';

/// Implementation of [TextIndexerBase] that constructs and maintains an
/// in-memory inverted index:
///
/// Use the [indexText] method to index a text document, returning a list
/// of [DocumentPostingsEntry] and adding it to the [postingsStream].
///
/// The [dictionary] and [postings] hashmaps are updated by [index]. Awaiting
/// the return value of [index] will ensure that [dictionary] and [postings]
/// updates have completed and are accessible.
///
/// The [loadTerms], [upsertDictionary], [loadTermPostings] and
/// [upsertTermPostings] implementations read and write from [dictionary] and
/// [postings] respectively.
@Deprecated('Implemention class `InMemoryIndexer` is deprecated, use factory '
    '`TextIndexer.async` instead.')
class InMemoryIndexer extends TextIndexerBase {
  //

  /// Initializes a [InMemoryIndexer] instance:
  /// - pass a [tokenizer] used by the indexer to parse  documents to tokens,
  ///   or use the default [TextIndexer.kDefaultTokenizer].
  /// - pass an in-memory [dictionary] instance, otherwise an empty
  ///   [Dictionary] will be initialized.
  /// - pass an in-memory [postings] instance, otherwise an empty [Postings]
  ///   will be initialized.
  InMemoryIndexer({
    Dictionary? dictionary,
    this.tokenizer = TextIndexer.kDefaultTokenizer,
    this.jsonTokenizer = TextIndexer.kDefaultJsonTokenizer,
    Postings? postings,
  }) : index = _InMemoryIndex(dictionary ?? {}, postings ?? {});

  @override
  final InvertedPositionalZoneIndex index;

  @override
  final Tokenizer tokenizer;

  @override
  final JsonTokenizer jsonTokenizer;
}

/// An implementation class for the [InMemoryIndexer], implements
/// [InvertedPositionalZoneIndex] interface:
/// - [dictionary] is the in-memory term dictionary for the indexer. Pass a
///   [dictionary] instance at instantiation, otherwise an empty [Dictionary]
///   will be initialized; and
/// - [postings] is the in-memory postings hashmap for the indexer. Pass a
///   [postings] instance at instantiation, otherwise an empty [Postings]
///   will be initialized.

class _InMemoryIndex implements InvertedPositionalZoneIndex {
  //
  /// The in-memory term dictionary for the indexer.
  final Dictionary dictionary;

  /// The in-memory postings hashmap for the indexer.
  final Postings postings;

  /// Instantiates a [_InMemoryIndex] instance:
  /// - [dictionary] is the in-memory term dictionary for the indexer. Pass a
  ///   [dictionary] instance at instantiation, otherwise an empty [Dictionary]
  ///   will be initialized; and
  /// - [postings] is the in-memory postings hashmap for the indexer. Pass a
  ///   [postings] instance at instantiation, otherwise an empty [Postings]
  ///   will be initialized.
  const _InMemoryIndex(this.dictionary, this.postings);

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
