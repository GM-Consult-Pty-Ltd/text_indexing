// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/src/_index.dart';

/// The InMemoryIndex is an implementation of the [InvertedIndex] interface
/// that mixes in [InvertedIndexMixin] and [InMemoryIndexMixin].
///
/// The InMemoryIndex is intended for fast indexing of a smaller corpus using
/// in-memory dictionary, k-gram and postings hashmaps.
class InMemoryIndex
    with InMemoryIndexMixin, InvertedIndexMixin
    implements InvertedIndex {
  //

  @override
  final int k;

  @override
  late DftMap dictionary;

  @override
  late KGramsMap kGramIndex;

  @override
  late PostingsMap postings;

  /// Instantiates a [InMemoryIndex] instance:
  /// - [tokenizer] is the [TextTokenizer] used to tokenize text for the index;
  /// - [k] is the length of k-gram entries in the k-gram index;
  /// - [zones] is a hashmap of zone names to their relative weight in the
  ///   index;
  /// - [phraseLength] is the maximum length of phrases in the index vocabulary
  ///   and must be greater than 0.
  /// - [dictionary] is the in-memory term dictionary for the indexer. Pass a
  ///   [DftMap] instance at instantiation, otherwise an empty [DftMap]
  ///   will be initialized;
  /// - [kGramIndex] is the in-memory [KGramsMap] for the index. Pass a
  ///   [KGramsMap] instance at instantiation, otherwise an empty [KGramsMap]
  ///   will be initialized; and
  /// - [postings] is the in-memory postings hashmap for the indexer. Pass a
  ///   [PostingsMap] instance at instantiation, otherwise an empty [PostingsMap]
  ///   will be initialized.
  InMemoryIndex(
      {required this.tokenizer,
      DftMap? dictionary,
      PostingsMap? postings,
      KGramsMap? kGramIndex,
      this.k = 2,
      this.zones = const <String, double>{},
      this.phraseLength = 1})
      : assert(phraseLength > 0, 'The phrase length must be 1 or greater') {
    this.dictionary = dictionary ?? {};
    this.postings = postings ?? {};
    this.kGramIndex = kGramIndex ?? {};
  }

  @override
  final TextTokenizer tokenizer;

  @override
  final ZoneWeightMap zones;

  @override
  final int phraseLength;
}

/// A mixin class that implements [InvertedIndex]. The mixin exposes in-memory
/// [dictionary] and [postings] fields that must be overriden. Provides
/// implementation of the following methods for operations on the in-memory
/// [postings] and [dictionary] maps:
/// - [vocabularyLength] returns the number of entries in the in-memory
///   [dictionary].
/// - [getDictionary] retrieves a [DftMap] for a collection of [Term]s from
///   the in-memory [dictionary] hashmap;
/// - [upsertDictionary ] inserts entries into the in-memory [dictionary] hashmap,
///   overwriting any existing entries;
/// - [getPostings] retrieves [PostingsMap] for a collection of [Term]s from the
///   in-memory [postings] hashmap;
/// - [upsertPostings] inserts entries into the in-memory [postings] hashmap,
///   overwriting any existing entries;
/// - [getKGramIndex] retrieves entries for a collection of [Term]s from the
///   in-memory [kGramIndex] hashmap; and
/// - [upsertKGramIndex] inserts entries into the in-memory [kGramIndex] hashmap,
///   overwriting any existing entries.
abstract class InMemoryIndexMixin implements InvertedIndex {
  //

  /// The in-memory term dictionary for the index.
  DftMap get dictionary;

  /// The in-memory postings hashmap for the index.
  PostingsMap get postings;

  /// The in-memory [KGramsMap] for the index.
  KGramsMap get kGramIndex;

  @override
  Future<Ft> get vocabularyLength async => dictionary.length;

  @override
  Future<PostingsMap> getPostings(Iterable<Term> terms) async {
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
  Future<DftMap> getDictionary([Iterable<Term>? terms]) async {
    if (terms == null) return dictionary;
    final DftMap retVal = {};
    for (final term in terms) {
      final entry = dictionary[term];
      if (entry != null) {
        retVal[term] = entry;
      }
    }
    return retVal;
  }

  @override
  Future<void> upsertDictionary(DftMap values) async =>
      dictionary.addAll(values);

  @override
  Future<void> upsertPostings(PostingsMap values) async =>
      postings.addAll(values);

  @override
  Future<KGramsMap> getKGramIndex(Iterable<KGram> kGrams) async {
    final KGramsMap retVal = {};
    for (final kGram in kGrams) {
      final entry = kGramIndex[kGram];
      if (entry != null) {
        retVal[kGram] = entry;
      }
    }
    return retVal;
  }

  @override
  Future<void> upsertKGramIndex(KGramsMap values) async =>
      kGramIndex.addAll(values);
}
