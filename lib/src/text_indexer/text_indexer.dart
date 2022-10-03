// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'dart:async';
import 'package:meta/meta.dart';
import 'package:text_indexing/src/_index.dart';

/// Interface for classes that construct and maintain an inverted, positional,
/// zoned index ([InvertedIndex]) and k-gram index ([KGramsMap]) for a
/// collection of documents (`corpus`).
///
/// Text or documents can be indexed by calling the following methods:
/// - [TextIndexer.indexJson] indexes the fields in a `Map<String, dynamic>` document;
/// - [TextIndexer.indexText] indexes text from a text document; and
/// - [indexCollection] indexes the fields of all the documents in a Map<String, dynamic>
///   document collection.
///
/// Alternatively, pass a [documentStream] or [collectionStream] for indexing
/// whenever either of these streams updateIndexes (a) document(s).
///
/// Implementing classes override the following fields:
/// - [index] is the [InvertedIndex] that provides access to the
///   index [DftMap] and [PostingsMap] and a [TextTokenizer];
/// - [documentStream] is an input stream of 'Map<String, dynamic>' documents. The documents
///   updateIndexested by[documentStream] are passed to [indexJson] for indexing; and
/// - [collectionStream] is an input stream of a collection of 'Map<String, dynamic>' documents.
///   The documents updateIndexested by [collectionStream] are passed to
///   [indexCollection] for indexing..
///
/// Implementing classes override the following asynchronous methods:
/// - [indexText] indexes a text document;
/// - [indexJson] indexes the fields in a Map<String, dynamic> document;
/// - [indexCollection] indexes the fields of all the documents in a Map<String, dynamic>
///   document collection; and
/// - [updateIndexes] updates the [DftMap], [PostingsMap] and [KGramsMap]
/// for this indexer.
abstract class TextIndexer {
  //

  /// Factory constructor initializes a [TextIndexer] instance, passing in a
  /// [index] instance:
  /// - [documentStream] is an input stream of 'Map<String, dynamic>' documents. The documents
  ///   updateIndexested by[documentStream] are passed to [indexJson] for indexing; and
  /// - [collectionStream] is an input stream of a collection of 'Map<String, dynamic>'
  ///   documents. The documents updateIndexested by [collectionStream] are passed to
  ///   [indexCollection] for indexing.
  factory TextIndexer(
          {required InvertedIndex index,
          Stream<MapEntry<String, Map<String, dynamic>>>? documentStream,
          Stream<Map<String, Map<String, dynamic>>>? collectionStream}) =>
      _TextIndexerImpl(index, collectionStream, documentStream);

  /// An input stream of 'Map<String, dynamic>' documents. The documents updateIndexested by
  /// [documentStream] are passed to [indexJson] for indexing.
  ///
  /// The key of the MapEntry<String, Map<String, dynamic>> is the primary key reference of the
  /// Map<String, dynamic> document.
  Stream<MapEntry<String, Map<String, dynamic>>>? get documentStream;

  /// An input stream of a collection of 'Map<String, dynamic>' documents. The documents updateIndexested
  /// by [documentStream] are passed to [indexCollection] for indexing.
  ///
  /// The key of the MapEntry<String, Map<String, dynamic>> is the primary key reference of the
  /// Map<String, dynamic> document.
  Stream<Map<String, Map<String, dynamic>>>? get collectionStream;

  /// The [updateIndexes] method is called by [index] and updates the
  /// [DftMap], [PostingsMap] and [KGramsMap] for this indexer.
  ///
  /// Sub-classes override [updateIndexes] to perform additional actions whenever a
  /// document is indexed.
  Future<void> updateIndexes(PostingsMap event, Iterable<Token> tokens);

  /// Indexes a text document, returning a [PostingsMap].
  Future<PostingsMap> indexText(String docId, SourceText docText);

  /// Indexes the [InvertedIndex.zones] in a [json] document, returning a list
  /// of [DocPostingsMapEntry].
  Future<PostingsMap> indexJson(String docId, Map<String, dynamic> json);

  /// Indexes the [InvertedIndex.zones] of all the documents in [collection].
  Future<void> indexCollection(Map<String, Map<String, dynamic>> collection);

  /// The [InvertedIndex] that provides access to the
  /// index [DftMap] and [PostingsMap] and a [TextTokenizer].
  InvertedIndex get index;

  //
}

/// Base class implementation of the [TextIndexer] interface.
///
/// Initializes listeners to [documentStream] and [collectionStream] at
/// instantiation.
///
/// Sub-classes must implement the [index] field.
abstract class TextIndexerBase implements TextIndexer {
  //

  /// Default generative constructor.
  ///
  /// Initializes listeners to [documentStream] and [collectionStream].
  TextIndexerBase() {
    documentStream?.listen((event) => indexJson(event.key, event.value));
    collectionStream?.listen((event) => indexCollection(event));
  }

  /// Implementation of [TextIndexer.indexText] that:
  /// - parses [docText] to a collection of [Token]s;
  /// - maps the tokens to postings for [docId];
  /// - maps the postings for [docId] to a [PostingsMap];
  /// - calls [updateIndexes], passing the [PostingsMap] for [docId]; and
  /// - returns the [PostingsMap] for [docId].
  @override
  Future<PostingsMap> indexText(String docId, SourceText docText) async {
    // get the terms using tokenizer
    final tokens = (await index.tokenizer.tokenize(docText));
    // map the tokens to postings
    final PostingsMap postings = _tokensToPostings(docId, tokens);
    // map postings to a list of DocPostingsMapEntry for docId.
    // final event = _postingsToTermPositions(docId, postings);
    // updateIndexes the postings list for docId
    await updateIndexes(postings, tokens);
    return postings;
  }

  /// Implementation of [TextIndexer.indexJson] that:
  /// - parses [json] to a collection of [Token]s in [index].zones. If
  ///   [index].zones is empty, tokenize all the fields in [json];
  /// - maps the tokens to postings for [docId];
  /// - maps the postings for [docId] to a [PostingsMap];
  /// - calls [updateIndexes], passing the [PostingsMap] for [docId]; and
  /// - returns the [PostingsMap] for [docId].
  @override
  Future<PostingsMap> indexJson(String docId, Map<String, dynamic> json) async {
    // get the terms using tokenizer
    final tokens = (await index.tokenizer.tokenizeJson(json, _zoneNames(json)));
    // map the tokens to postings
    final PostingsMap postings = _tokensToPostings(docId, tokens);
    // update the indexes with the postings list for docId
    await updateIndexes(postings, tokens);
    return postings;
  }

  /// Private helper function that returns the zone names for mapping [json] to
  /// tokens:
  /// - returns index.zones if it is not empty, otherwise
  /// - returns the keys of all entries in [json] that have [String] values.
  Set<String> _zoneNames(Map<String, dynamic> json) {
    if (index.zones.isNotEmpty) {
      return index.zones.keys.toSet();
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
  Future<void> indexCollection(
      Map<String, Map<String, dynamic>> collection) async {
    await Future.forEach(collection.entries,
        (MapEntry<String, Map<String, dynamic>> e) async {
      final docId = e.key;
      final json = e.value;
      await indexJson(docId, json);
    });
  }

  /// Maps the [tokens] to a [PostingsMap] by creating a [ZonePostingsMap] for
  /// every element in [tokens].
  ///
  /// Also adds a [ZonePostingsMap] entry for term pairs in [tokens].
  PostingsMap _tokensToPostings(String docId, Iterable<Token> tokens) {
    // initialize a PostingsMap collection to hold the postings
    final PostingsMap postings = {};
    // initialize the term position index
    final phraseTerms = [];
    for (var token in tokens) {
      final term = token.term;
      if (term.isNotEmpty) {
        // add a term position to postings
        postings.addTermPosition(
            term: term,
            docId: docId,
            zone: token.zone,
            position: token.termPosition);
        phraseTerms.add(term);
        if (phraseTerms.length > index.phraseLength) {
          phraseTerms.removeAt(0);
        }
        if (phraseTerms.length > 1) {
          final phrase = phraseTerms.join(' ');
          // add the term
          postings.addTermPosition(
              term: phrase,
              docId: docId,
              zone: token.zone,
              position: token.termPosition);
        }
      }
    }
    return postings;
  }

  Future<void> _upsertKgrams(Iterable<Token> tokens) async {
    // - get the new kGrams for the tokens;
    final newkGrams = tokens.kGrams(index.k);
    final persistedKgrams = await index.getKGramIndex(newkGrams.keys);
    newkGrams.forEach((key, value) {
      final kGramEntry = persistedKgrams[key] ?? {};
      kGramEntry.addAll(value);
      persistedKgrams[key] = kGramEntry;
    });
    await index.upsertKGramIndex(persistedKgrams);
  }

  /// Implementation of [TextIndexer.updateIndexes] that:
  /// - maps [event] to a set of unique terms;
  /// - loads the existing [PostingsMapEntry]s for the terms from the [index]
  ///   [PostingsMap];
  /// - loads the existing [DftMapEntry]s for the terms from the [index];
  /// - iterates through the [event] entries and:
  /// - inserts or updates each [DocPostingsMapEntry] instance to the index
  ///   [PostingsMap];
  /// - if a [DocPostingsMapEntry] instance did not exist previously,
  ///   increments the document frequency of the associated term;
  /// - then:
  /// - asynchronously updates the index [DftMap]; and
  /// - asynchronously updates the index [PostingsMap].
  @override
  @mustCallSuper
  Future<void> updateIndexes(PostingsMap event, Iterable<Token> tokens) async {
    // - maps [event] to a set of unique terms;
    final terms = Set<Term>.from(event.keys);
    await _upsertKgrams(tokens);

    // - loads the existing [PostingsMapEntry]s for the terms from a [PostingsMap] by calling [getPostings];
    final postingsToUpdate = await index.getPostings(terms);
// - loads the existing [DftMapEntry]s for the terms from a [DftMap] by calling [getDictionary];
    final DftMap termsToUpdate = await index.getDictionary(terms);
    // - iterates through the [DocPostingsMapEntry] in [event];
    await Future.forEach(event.entries, (PostingsMapEntry entry) {
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
    });
    // - asynchronously updates the [DftMap] by calling [upsertDictionary];
    await index.upsertDictionary(termsToUpdate);
    // - asynchronously updates the [PostingsMap] by calling [upsertPostings]; and
    await index.upsertPostings(postingsToUpdate);
  }
}

/// Private implementation class returned by [TextIndexer]'s unnamed factory
/// constructor.
class _TextIndexerImpl extends TextIndexerBase {
  //

  @override
  final InvertedIndex index;

  /// Default constructor
  _TextIndexerImpl(this.index, this.collectionStream, this.documentStream);

  @override
  final Stream<Map<String, Map<String, dynamic>>>? collectionStream;

  @override
  final Stream<MapEntry<String, Map<String, dynamic>>>? documentStream;
}
