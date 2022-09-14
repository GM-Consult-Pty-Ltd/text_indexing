// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/text_indexing.dart';

/// Implementation of [TextIndexerBase] that constructs and maintains an
/// in-memory inverted index:
///
/// The [dictionary] is the in-memory term dictionary for the indexer. Pass a
/// [dictionary] instance at instantiation, otherwise an empty [Dictionary]
/// will be initialized.
///
/// The [postings] is the in-memory postings hashmap for the indexer. Pass a
/// [postings] instance at instantiation, otherwise an empty [Postings]
/// will be initialized.
///
/// Use the [index] method to index a text document, returning a list
/// of [PostingsMap] and adding it to the [postingsStream].
///
/// The [dictionary] and [postings] hashmaps are updated by [index]. Awaiting
/// the return value of [index] will ensure that [dictionary] and [postings]
/// updates have completed and are accessible.
///
/// The [loadTerms], [updateDictionary], [loadTermPostings] and
/// [upsertTermPostings] implementations read and write from [dictionary] and
/// [postings] respectively.
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
  })  : postings = postings ?? {},
        dictionary = dictionary ?? {};

  /// The in-memory term dictionary for the indexer.
  final Dictionary dictionary;

  /// The in-memory postings hashmap for the indexer.
  final Postings postings;

  @override
  final Tokenizer tokenizer;

  @override
  final JsonTokenizer jsonTokenizer;

  /// Implementation of [TextIndexer.loadTermPostings].
  ///
  /// Returns a subset of [postings] corresponding to [terms].
  @override
  Future<Postings> loadTermPostings(Iterable<String> terms) async {
    final Postings retVal = {};
    for (final term in terms) {
      final entry = postings[term];
      if (entry != null) {
        retVal[term] = entry;
      }
    }
    return retVal;
  }

  /// Implementation of [TextIndexer.updateDictionary].
  ///
  /// Adds/overwrites the [values] to [dictionary].
  @override
  Future<void> updateDictionary(Dictionary values) async {
    dictionary.addAll(values);
  }

  /// Implementation of [TextIndexer.upsertTermPostings].
  ///
  /// Adds/overwrites the [values] to [postings].
  @override
  Future<void> upsertTermPostings(Postings values) async {
    postings.addAll(values);
  }

  /// Implementation of [TextIndexer.loadTerms].
  ///
  /// Returns a subset of [dictionary] corresponding to [terms].
  @override
  Future<Dictionary> loadTerms(Iterable<String> terms) async {
    final Dictionary retVal = {};
    for (final term in terms) {
      final entry = dictionary[term];
      if (entry != null) {
        retVal[term] = entry;
      }
    }
    return retVal;
  }
}
