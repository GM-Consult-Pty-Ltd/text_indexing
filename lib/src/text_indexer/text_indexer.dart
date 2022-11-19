// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'dart:async';
import 'package:meta/meta.dart';
import 'package:text_indexing/src/_index.dart';

/// Interface for classes that construct and maintain a [InvertedIndex] for a
/// collection of documents (`corpus`).
///
/// Text or documents can be indexed by calling the following methods:
/// - [TextIndexer.indexJson] indexes the fields in a `Map<String, dynamic>` document;
/// - [TextIndexer.indexText] indexes text from a text document;
/// - [TextIndexer.indexTokens] indexes text from a text document;
/// - [TextIndexer.indexDocumentStream] indexes documents emitted by a stream
///   of {docId : document} map entries;
/// - [TextIndexer.indexCollectionStream] indexes the documents emitted by a
///   [JsonCollection] stream; and
/// - [indexCollection] indexes the fields of all the documents in a Map<String, dynamic>
///   document collection.
abstract class TextIndexer implements InvertedIndex {
  //

  /// The [updateIndexes] method updates the [DftMap], [PostingsMap],
  /// [KeywordPostingsMap] and [KGramsMap].
  ///
  /// Sub-classes override [updateIndexes] to perform additional actions whenever a
  /// document is indexed.
  Future<void> updateIndexes(PostingsMap postings,
      KeywordPostingsMap keywordPostings, Iterable<Token> tokens);

  /// Indexes a text document, returning a [PostingsMap].
  Future<void> indexText(String docId, String docText,
      {String? zone, TokenFilter? tokenFilter});

  /// Indexes the [InvertedIndex.zones] in a [json] document, returning a list
  /// of [DocPostingsMapEntry].
  Future<void> indexJson(String docId, Map<String, dynamic> json,
      {TokenFilter? tokenFilter});

  /// Indexes the [InvertedIndex.zones] of all the documents in [collection].
  Future<void> indexCollection(Map<String, Map<String, dynamic>> collection,
      {TokenFilter? tokenFilter});

  /// Updates the index with the [tokens] for [docId].
  Future<void> indexTokens(String docId, Iterable<Token> tokens);

  /// Indexes the documents emitted by [documentStream].
  void indexDocumentStream(Stream<MapEntry<String, JSON>> documentStream,
      {TokenFilter? tokenFilter});

  /// Indexes the documents emitted by [collectionStream].
  void indexCollectionStream(Stream<JsonCollection> collectionStream,
      {TokenFilter? tokenFilter});

  /// Cancels any stream all listeners.
  Future<void> dispose();
}

// /// Abstract base class implementation of [TextIndexer] with [TextIndexerMixin].
// abstract class TextIndexerBase with TextIndexerMixin {
//   //

//   /// Default generative constructor.
//   TextIndexerBase();
// }

/// Mixin class implementation of the [TextIndexer] interface.
abstract class TextIndexerMixin implements TextIndexer {
  //

  StreamSubscription<JsonCollection>? _jsonCollectionListener;

  @override
  void indexCollectionStream(Stream<JsonCollection> collectionStream,
      {TokenFilter? tokenFilter}) {
    _jsonCollectionListener = collectionStream
        .listen((event) => indexCollection(event, tokenFilter: tokenFilter));
  }

  StreamSubscription<MapEntry<String, JSON>>? _jsonDocumentListener;
  @override
  void indexDocumentStream(Stream<MapEntry<String, JSON>> documentStream,
      {TokenFilter? tokenFilter}) {
    _jsonDocumentListener = documentStream.listen(
        (event) => indexJson(event.key, event.value, tokenFilter: tokenFilter));
  }

  @mustCallSuper
  @override
  Future<void> dispose() async {
    await _jsonCollectionListener?.cancel();
    await _jsonDocumentListener?.cancel();
  }

  /// Implementation of [TextIndexer.indexText] that:
  /// - parses [docText] to a collection of [Token]s;
  /// - maps the tokens to postings for [docId];
  /// - maps the postings for [docId] to a [PostingsMap];
  /// - calls [updateIndexes], passing the [PostingsMap] for [docId]; and
  /// - returns the [PostingsMap] for [docId].
  @override
  Future<void> indexText(String docId, String docText,
      {bool preserveCase = false,
      String? zone,
      TokenFilter? tokenFilter}) async {
    // get the terms using tokenizer
    final tokens = (await analyzer.tokenizer(docText,
        tokenFilter: tokenFilter, nGramRange: nGramRange, zone: zone));
    await indexTokens(docId, tokens);
  }

  /// Implementation of [TextIndexer.indexJson] that:
  /// - parses [json] to a collection of [Token]s in [zones]. If[zones] is
  ///   empty, tokenize all the fields in [json];
  /// - maps the tokens to postings for [docId];
  /// - maps the postings for [docId] to a [PostingsMap];
  /// - calls [updateIndexes], passing the [PostingsMap] for [docId]; and
  /// - returns the [PostingsMap] for [docId].
  @override
  Future<void> indexJson(String docId, Map<String, dynamic> json,
      {TokenFilter? tokenFilter}) async {
    // get the terms using tokenizer
    final zones = _zoneNames(json);
    final tokens = (await analyzer.jsonTokenizer(json,
        tokenFilter: tokenFilter, zones: zones, nGramRange: nGramRange));
    await indexTokens(docId, tokens);
  }

  @override
  Future<void> indexTokens(String docId, Iterable<Token> tokens) async {
    final KeywordPostingsMap keyWords = _keywordsToPostings(docId, tokens);
    // map the tokens to postings
    final PostingsMap postings = _tokensToPostings(docId, tokens);
    // update the indexes with the postings list for docId
    await updateIndexes(postings, keyWords, tokens);
  }

  /// Private helper function that returns the zone names for mapping [json] to
  /// tokens:
  /// - returns zones if it is not empty, otherwise
  /// - returns the keys of all entries in [json] that have [String] values.
  Set<String> _zoneNames(Map<String, dynamic> json) {
    if (this.zones.isNotEmpty) {
      return this.zones.keys.toSet();
    }
    final zones = <String>{};
    for (final entry in json.entries) {
      if (entry.value is String) {
        zones.add(entry.key);
      }
    }
    return zones;
  }

  /// Implementation of [TextIndexer.indexCollection] that parses each Map<String, dynamic>
  /// document in [collection] to [Token]s and maps the tokens to a [PostingsMap]
  /// that is passed to [updateIndexes].
  @override
  Future<void> indexCollection(Map<String, Map<String, dynamic>> collection,
      {TokenFilter? tokenFilter}) async {
    await Future.forEach(collection.entries,
        (MapEntry<String, Map<String, dynamic>> e) async {
      final docId = e.key;
      final json = e.value;
      await indexJson(docId, json, tokenFilter: tokenFilter);
    });
  }

  /// Maps the [tokens] to a [PostingsMap] by creating a [ZonePostingsMap] for
  /// every element in [tokens].
  ///
  /// Also adds a [ZonePostingsMap] entry for term pairs in [tokens].
  KeywordPostingsMap _keywordsToPostings(String docId, Iterable<Token> tokens) {
    // final keywords = <List<String>>[];
    // final termSet = <String>{};
    // for (final e in tokens) {
    //   final term = e.term.trim();
    //   if (termSet.add(term)) {
    //     final kw = term.split(RegExp(r'\s+'));
    //     if (kw.isNotEmpty) {
    //       keywords.add(kw);
    //     }
    //   }
    // }
    final graph = TermCoOccurrenceGraph(
        tokens.allTerms.map((e) => e.splitAtWhitespace()));
    final keyWordsMap = graph.keywordScores;
    final emptyKeywords = keyWordsMap.keys
        .map((e) => e.trim())
        .where((element) => element.isEmpty);
    if (emptyKeywords.isNotEmpty) {
      print('Found ${emptyKeywords.length} empty keywords');
    }
    // initialize a KeywordPostingsMap collection to hold the postings
    final KeywordPostingsMap postings = {};
    // initialize the term position index
    // final phraseTerms = [];
    for (var entry in keyWordsMap.entries) {
      // add a term position to postings
      postings.addDocKeywordScore(entry.key, docId, entry.value);
    }
    return postings;
  }

  /// Maps the [tokens] to a [PostingsMap] by creating a [ZonePostingsMap] for
  /// every element in [tokens].
  ///
  /// Also adds a [ZonePostingsMap] entry for term pairs in [tokens].
  PostingsMap _tokensToPostings(String docId, Iterable<Token> tokens) {
    // initialize a PostingsMap collection to hold the postings
    final PostingsMap postings = {};
    // initialize the term position index
    // final phraseTerms = [];
    for (var token in tokens) {
      final term = token.term;
      if (term.isNotEmpty) {
        // add a term position to postings
        postings.addTermPosition(
            term: term,
            docId: docId,
            zone: token.zone,
            position: token.termPosition);
      }
    }
    return postings;
  }

  Future<void> _upsertKgrams(Iterable<Token> tokens) async {
    // - get the new kGrams for the tokens;
    final terms = <String>{}..addAll(tokens.map((e) => e.term));
    final newkGrams = terms.toKGramsMap(k);
    final persistedKgrams = await getKGramIndex(newkGrams.keys);
    newkGrams.forEach((key, value) {
      final kGramEntry = persistedKgrams[key] ?? {};
      kGramEntry.addAll(value);
      persistedKgrams[key] = kGramEntry;
    });
    await upsertKGramIndex(persistedKgrams);
  }

  /// Implementation of [TextIndexer.updateIndexes].
  @override
  @mustCallSuper
  Future<void> updateIndexes(PostingsMap postings,
      KeywordPostingsMap keywordPostings, Iterable<Token> tokens) async {
    // update the k-gram index
    await _upsertKgrams(tokens);
    // update the document term frequency index and postings index
    await _updatePostings(postings);
    // update the keywords index
    await _updateKeywordsIndex(keywordPostings);
  }

  Future<void> _updateKeywordsIndex(KeywordPostingsMap keywordPostings) async {
    final keyWordsToUpdate = await getKeywordPostings(keywordPostings.keys);
    for (final entry in keywordPostings.entries) {
      final keyword = entry.key;
      final scores = entry.value;
      final existingEntry = keyWordsToUpdate[keyword] ?? {};
      existingEntry.addAll(scores);
      keyWordsToUpdate[keyword] = existingEntry;
    }
    await upsertKeywordPostings(keyWordsToUpdate);
  }

  Future<void> _updatePostings(PostingsMap event) async {
    // - maps [event] to a set of unique terms;
    final terms = Set<String>.from(event.keys);
    // - loads the existing [PostingsMapEntry]s for the terms from a [PostingsMap] by calling [getPostings];
    final postingsToUpdate = await getPostings(terms);
    // - loads the existing [DftMapEntry]s for the terms from a [DftMap] by calling [getDictionary];
    final DftMap termsToUpdate = await getDictionary(terms);
    // - iterates through the [DocPostingsMapEntry] in [event];
    for (final entry in event.entries) {
      final term = entry.key;
      final postings = entry.value;
      for (final docEntry in postings.entries) {
        final docId = docEntry.key;
        final fieldPostings = docEntry.value;
        // - inserts or updates each [DocPostingsMapEntry] instance to a collection of postings to update;
        final increment =
            postingsToUpdate.addZonePostings(term, docId, fieldPostings);
        // - if a [DocPostingsMapEntry] instance did not exist previously, also increments the document frequency of the associated term;
        if (increment) {
          termsToUpdate.incrementFrequency(term);
        }
      }
    }
    // - asynchronously updates the [DftMap] by calling [upsertDictionary];
    await upsertDictionary(termsToUpdate);
    // - asynchronously updates the [PostingsMap] by calling [upsertPostings]; and
    await upsertPostings(postingsToUpdate);
  }
}

// /// Private implementation class returned by [TextIndexer]'s unnamed factory
// /// constructor.
// class _TextIndexerImpl extends TextIndexerBase {
//   //

//   final InvertedIndex index;

//   /// Default constructor, initializes stream listeners to index documents
//   /// as they are emitted by either or both streams.
//   _TextIndexerImpl(this.index, {this.collectionStream, this.documentStream}) {
//     documentStream?.listen((event) => indexJson(event.key, event.value));
//     collectionStream?.listen((event) => indexCollection(event));
//   }

//   @override
//   final Stream<Map<String, Map<String, dynamic>>>? collectionStream;

//   @override
//   final Stream<MapEntry<String, Map<String, dynamic>>>? documentStream;

//   @override
//   TextAnalyzer get analyzer => index.analyzer;

//   @override
//   Future<int> getCollectionSize() => index.getCollectionSize();

//   @override
//   Future<DftMap> getDictionary([Iterable<String>? terms]) =>
//       index.getDictionary(terms);

//   @override
//   Future<KGramsMap> getKGramIndex(Iterable<String> kGrams) =>
//       index.getKGramIndex(kGrams);

//   @override
//   Future<KeywordPostingsMap> getKeywordPostings(Iterable<String> keywords) =>
//       index.getKeywordPostings(keywords);

//   @override
//   Future<PostingsMap> getPostings(Iterable<String> terms) =>
//       index.getPostings(terms);

//   @override
//   int get k => index.k;

//   @override
//   NGramRange? get nGramRange => index.nGramRange;

//   // @override
//   // TokenFilter? get tokenFilter => index.tokenFilter;

//   @override
//   Future<void> upsertDictionary(DftMap values) {
//     // TODO: implement upsertDictionary
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> upsertKGramIndex(KGramsMap values) {
//     // TODO: implement upsertKGramIndex
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> upsertKeywordPostings(KeywordPostingsMap values) {
//     // TODO: implement upsertKeywordPostings
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> upsertPostings(PostingsMap values) {
//     // TODO: implement upsertPostings
//     throw UnimplementedError();
//   }

//   @override
//   // TODO: implement vocabularyLength
//   Future<Ft> get vocabularyLength => throw UnimplementedError();

//   @override
//   // TODO: implement zones
//   ZoneWeightMap get zones => throw UnimplementedError();
// }
