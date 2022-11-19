// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/src/_index.dart';

/// The InMemoryIndex is an implementation of the [InvertedIndex] interface
/// that extends [InMemoryIndexBase].
///
/// The InMemoryIndex is intended for fast indexing of a smaller corpus using
/// in-memory dictionary, k-gram and postings hashmaps.
class InMemoryIndex extends InMemoryIndexBase {
  //
  @override
  final int collectionSize;

  @override
  final int k;

  @override
  final NGramRange? nGramRange;

  @override
  late DftMap dictionary;

  @override
  late KGramsMap kGramIndex;

  @override
  late PostingsMap postings;

  @override
  late KeywordPostingsMap keywordPostings;

  @override
  final TextAnalyzer analyzer;

  @override
  final ZoneWeightMap zones;

  /// Instantiates a [InMemoryIndex] instance.
  /// - [analyzer] is the [TextAnalyzer] used to tokenize text for the index;
  /// - [collectionSize] is the size of the indexed collection.
  /// - [k] is the length of k-gram entries in the k-gram index.
  /// - [nGramRange] is the range of N-gram lengths to generate. If [nGramRange]
  ///   is null, only keyword phrases are generated.
  /// - [zones] is a hashmap of zone names to their relative weight in the
  ///   index.
  /// - [dictionary] is the in-memory term dictionary for the indexer. Pass a
  ///   [DftMap] instance at instantiation, otherwise an empty [DftMap]
  ///   will be initialized.
  /// - [kGramIndex] is the in-memory [KGramsMap] for the index. Pass a
  ///   [KGramsMap] instance at instantiation, otherwise an empty [KGramsMap]
  ///   will be initialized.
  /// - [postings] is the in-memory postings hashmap for the indexer. Pass a
  ///   [PostingsMap] instance at instantiation, otherwise an empty [PostingsMap]
  ///   will be initialized.
  /// - [keywordPostings] is the in-memory postings hashmap for the indexer. Pass a
  ///   [PostingsMap] instance at instantiation, otherwise an empty [PostingsMap]
  ///   will be initialized.
  InMemoryIndex(
      {required this.analyzer,
      required this.collectionSize,
      DftMap? dictionary,
      PostingsMap? postings,
      KeywordPostingsMap? keywordPostings,
      KGramsMap? kGramIndex,
      this.k = 2,
      this.nGramRange,
      this.zones = const <String, double>{}}) {
    this.dictionary = dictionary ?? {};
    this.postings = postings ?? {};
    this.keywordPostings = keywordPostings ?? {};
    this.kGramIndex = kGramIndex ?? {};
  }

  //
}

/// Base class implementation of [InvertedIndex] with [InMemoryIndexMixin].
///
/// Provides a const default generative constructor for sub-classes.
abstract class InMemoryIndexBase
    with InMemoryIndexMixin, TextIndexerMixin
    implements InvertedIndex {
  //

  // @override
  // InvertedIndex get index => this;

  /// Const default generative constructor for sub-classes.
  InMemoryIndexBase();

  //
}

/// A mixin class that implements [InvertedIndex]. The mixin exposes in-memory
/// [dictionary] and [postings] fields that must be overriden.
///
/// Implements the following methods for operations on the in-memory [postings],
/// [keywordPostings] and [dictionary] maps:
/// - [vocabularyLength] returns the number of entries in the in-memory
///   [dictionary].
/// - [getDictionary] retrieves a [DftMap] for a collection of terms from
///   the in-memory [dictionary] hashmap;
/// - [upsertDictionary ] inserts entries into the in-memory [dictionary] hashmap,
///   overwriting any existing entries;
/// - [getPostings] retrieves [PostingsMap] for a collection of terms from the
///   in-memory [postings] hashmap;
/// - [upsertPostings] inserts entries into the in-memory [postings] hashmap,
///   overwriting any existing entries;
/// - [getKeywordPostings] retrieves [KeywordPostingsMap] for a collection of
///   keywords from the in-memory [keywordPostings] hashmap;
/// - [upsertKeywordPostings] inserts entries into the in-memory
///   [keywordPostings] hashmap, overwriting any existing entries;
/// - [getKGramIndex] retrieves entries for a collection of terms from the
///   in-memory [kGramIndex] hashmap; and
/// - [upsertKGramIndex] inserts entries into the in-memory [kGramIndex] hashmap,
///   overwriting any existing entries.
abstract class InMemoryIndexMixin implements InvertedIndex {
  //

  /// Returns the size of the indexed collection.
  int get collectionSize;

  @override
  Future<int> getCollectionSize() async => collectionSize;

  /// The in-memory term dictionary for the index.
  DftMap get dictionary;

  /// The in-memory postings hashmap for the index.
  PostingsMap get postings;

  /// The in-memory [KGramsMap] for the index.
  KGramsMap get kGramIndex;

  /// The in-memory keyword postings hashmap for the index.
  KeywordPostingsMap get keywordPostings;

  @override
  Future<Ft> get vocabularyLength async => dictionary.length;

  @override
  Future<KeywordPostingsMap> getKeywordPostings(
      Iterable<String> keywords) async {
    final KeywordPostingsMap retVal = {};
    for (final e in keywords) {
      final entry = keywordPostings[e];
      if (entry != null) {
        retVal[e] = entry;
      }
    }
    return retVal;
  }

  @override
  Future<void> upsertKeywordPostings(KeywordPostingsMap values) async {
    keywordPostings.addAll(values);
  }

  @override
  Future<PostingsMap> getPostings(Iterable<String> terms) async {
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
  Future<DftMap> getDictionary([Iterable<String>? terms]) async {
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
  Future<KGramsMap> getKGramIndex(Iterable<String> kGrams) async {
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
