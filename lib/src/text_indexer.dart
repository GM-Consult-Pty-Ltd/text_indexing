// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'dart:async';
import 'package:meta/meta.dart';
import 'package:text_indexing/text_indexing.dart';

/// Alias for Map<String, dynamic>, a hashmap known as "Java Script Object
/// Notation" (JSON), a common format for persisting data.
typedef JSON = Map<Zone, dynamic>;

/// Alias for Map<String, Map<String, dynamic>>, a hashmap of [DocId] to [JSON]
/// documents.
typedef JsonCollection = Map<DocId, JSON>;

/// Interface for classes that construct and maintain a inverted, positional,
/// zoned index [InvertedIndex].
///
/// Text or documents can be indexed by calling the following methods:
/// - [TextIndexer.indexJson] indexes the fields in a `JSON` document;
/// - [TextIndexer.indexText] indexes text from a text document.
///
/// Alternatively, pass a [documentStream] or [collectionStream] for indexing
/// whenever either of these streams updateIndexes (a) document(s).
///
/// Implementing classes override the following fields:
/// - [index] is the [InvertedIndex] that provides access to the
///   index [Dictionary] and [Postings] and a [ITextAnalyzer];
/// - [documentStream] is an input stream of 'JSON' documents. The documents
///   updateIndexested by[documentStream] are passed to [indexJson] for indexing; and
/// - [collectionStream] is an input stream of a collection of 'JSON' documents.
///   The documents updateIndexested by [collectionStream] are passed to
///   [indexCollection] for indexing..
///
/// Implementing classes override the following asynchronous methods:
/// - [indexText] indexes a text document;
/// - [indexJson] indexes the fields in a JSON document;
/// - [indexCollection] indexes the fields of all the documents in a JSON
///   document collection; and
/// - [updateIndexes] updates the [Dictionary], [Postings] and [KGramIndex]
/// for this indexer.
abstract class TextIndexer {
  //

  /// A const constructor for sub classes
  const TextIndexer();

  /// Factory constructor returns a [TextIndexer] instance with in-memory
  /// [Dictionary] and [Postings] maps:
  /// - pass a [analyzer] text analyser that extracts tokens from text;
  /// - pass an in-memory [dictionary] instance, otherwise an empty
  ///   [Dictionary] will be initialized;
  /// - pass an in-memory [postings] instance, otherwise an empty [Postings]
  ///   will be initialized;
  /// - [documentStream] is an input stream of 'JSON' documents. The documents
  ///   updateIndexested by[documentStream] are passed to [indexJson] for indexing; and
  /// - [collectionStream] is an input stream of a collection of 'JSON'
  ///   documents. The documents updateIndexested by [collectionStream] are passed to
  ///   [indexCollection] for indexing.
  factory TextIndexer.inMemory(
          {Dictionary? dictionary,
          Postings? postings,
          KGramIndex? kGramIndex,
          ZoneWeightMap? zones,
          int k = 3,
          int phraseLength = 1,
          ITextAnalyzer analyzer = const TextAnalyzer(),
          Stream<MapEntry<DocId, JSON>>? documentStream,
          Stream<Map<DocId, JSON>>? collectionStream}) =>
      _TextIndexerImpl(
          InMemoryIndex(
            dictionary: dictionary ?? {},
            postings: postings ?? {},
            analyzer: analyzer,
            zones: zones ?? {},
            kGramIndex: kGramIndex ?? {},
            phraseLength: phraseLength,
            k: k,
          ),
          collectionStream,
          documentStream);

  /// Factory constructor returns a [TextIndexer] instance that uses
  /// asynchronous callback functions to access [Dictionary] and [Postings]
  /// repositories:
  /// - pass a [analyzer] text analyser that extracts tokens from text;
  /// - [dictionaryLoader] synchronously retrieves a [Dictionary] for a vocabulary
  ///   from a data source;
  /// - [dictionaryLengthLoader] asynchronously retrieves the number of terms in
  ///   the vocabulary (N);
  /// - [dictionaryUpdater] is callback that passes a [Dictionary] subset
  ///    for persisting to a datastore;
  /// - [postingsLoader] asynchronously retrieves a [Postings] for a vocabulary
  ///   from a data source;
  /// - [postingsUpdater] passes a [Postings] subset for persisting to a
  ///   datastore;
  /// - [documentStream] is an input stream of 'JSON' documents. The documents
  ///   updateIndexested by[documentStream] are passed to [indexJson] for indexing; and
  /// - [collectionStream] is an input stream of a collection of 'JSON'
  ///   documents. The documents updateIndexested by [collectionStream] are passed to
  ///   [indexCollection] for indexing.
  factory TextIndexer.async(
          {required DictionaryLoader dictionaryLoader,
          required DictionaryUpdater dictionaryUpdater,
          required DictionaryLengthLoader dictionaryLengthLoader,
          required KGramIndexLoader kGramIndexLoader,
          required KGramIndexUpdater kGramIndexUpdater,
          required PostingsLoader postingsLoader,
          required PostingsUpdater postingsUpdater,
          Stream<MapEntry<DocId, JSON>>? documentStream,
          Stream<Map<DocId, JSON>>? collectionStream,
          ITextAnalyzer analyzer = const TextAnalyzer()}) =>
      _TextIndexerImpl(
          AsyncCallbackIndex(
              dictionaryLoader: dictionaryLoader,
              dictionaryUpdater: dictionaryUpdater,
              dictionaryLengthLoader: dictionaryLengthLoader,
              kGramIndexLoader: kGramIndexLoader,
              kGramIndexUpdater: kGramIndexUpdater,
              postingsLoader: postingsLoader,
              postingsUpdater: postingsUpdater,
              analyzer: analyzer),
          collectionStream,
          documentStream);

  /// Factory constructor initializes a [TextIndexer] instance, passing in a
  /// [index] instance:
  /// - [documentStream] is an input stream of 'JSON' documents. The documents
  ///   updateIndexested by[documentStream] are passed to [indexJson] for indexing; and
  /// - [collectionStream] is an input stream of a collection of 'JSON'
  ///   documents. The documents updateIndexested by [collectionStream] are passed to
  ///   [indexCollection] for indexing.
  factory TextIndexer.index(
          {required InvertedIndex index,
          Stream<MapEntry<DocId, JSON>>? documentStream,
          Stream<Map<DocId, JSON>>? collectionStream}) =>
      _TextIndexerImpl(index, collectionStream, documentStream);

  /// An input stream of 'JSON' documents. The documents updateIndexested by
  /// [documentStream] are passed to [indexJson] for indexing.
  ///
  /// The key of the MapEntry<DocId, JSON> is the primary key reference of the
  /// JSON document.
  Stream<MapEntry<DocId, JSON>>? get documentStream;

  /// An input stream of a collection of 'JSON' documents. The documents updateIndexested
  /// by [documentStream] are passed to [indexCollection] for indexing.
  ///
  /// The key of the MapEntry<DocId, JSON> is the primary key reference of the
  /// JSON document.
  Stream<Map<DocId, JSON>>? get collectionStream;

  /// The [updateIndexes] method is called by [index] and updates the
  /// [Dictionary], [Postings] and [KGramIndex] for this indexer.
  ///
  /// Sub-classes override [updateIndexes] to perform additional actions whenever a
  /// document is indexed.
  Future<void> updateIndexes(Postings event, Iterable<Token> tokens);

  /// Indexes a text document, returning a [Postings].
  Future<Postings> indexText(DocId docId, SourceText docText);

  /// Indexes the [InvertedIndex.zones] in a [json] document, returning a list
  /// of [DocumentPostingsEntry].
  Future<Postings> indexJson(DocId docId, JSON json);

  /// Indexes the [InvertedIndex.zones] of all the documents in [collection].
  Future<void> indexCollection(JsonCollection collection);

  /// The [InvertedIndex] that provides access to the
  /// index [Dictionary] and [Postings] and a [ITextAnalyzer].
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
  /// - maps the postings for [docId] to a [Postings];
  /// - calls [updateIndexes], passing the [Postings] for [docId]; and
  /// - returns the [Postings] for [docId].
  @override
  Future<Postings> indexText(DocId docId, SourceText docText) async {
    // get the terms using tokenizer
    final tokens = (await index.analyzer.tokenize(docText));
    // map the tokens to postings
    final Postings postings = _tokensToPostings(docId, tokens);
    // map postings to a list of DocumentPostingsEntry for docId.
    // final event = _postingsToTermPositions(docId, postings);
    // updateIndexes the postings list for docId
    await updateIndexes(postings, tokens);
    return postings;
  }

  /// Implementation of [TextIndexer.indexJson] that:
  /// - parses [json] to a collection of [Token]s;
  /// - maps the tokens to postings for [docId];
  /// - maps the postings for [docId] to a [Postings];
  /// - calls [updateIndexes], passing the [Postings] for [docId]; and
  /// - returns the [Postings] for [docId].
  @override
  Future<Postings> indexJson(DocId docId, JSON json) async {
    // get the terms using tokenizer
    final tokens = (await index.analyzer.tokenizeJson(json, index.zones.keys));
    // map the tokens to postings
    if (tokens.terms.contains('alphabet')) {
      print(tokens.terms);
    }
    final Postings postings = _tokensToPostings(docId, tokens);
    // map postings to a list of DocumentPostingsEntry for docId.
    // final event = _postingsToTermPositions(docId, postings);
    // update the indexes with the postings list for docId
    await updateIndexes(postings, tokens);
    return postings;
  }

  /// Implementation of [TextIndexer.indexCollection] that parses each JSON
  /// document in [collection] to [Token]s and maps the tokens to a [Postings]
  /// that is passed to [updateIndexes].
  @override
  Future<void> indexCollection(JsonCollection collection) async {
    await Future.forEach(collection.entries, (MapEntry<DocId, JSON> e) async {
      final docId = e.key;
      final json = e.value;
      await indexJson(docId, json);
    });
  }

  /// Maps the [tokens] to a [Postings] by creating a [ZonePostings] for
  /// every element in [tokens].
  ///
  /// Also adds a [ZonePostings] entry for term pairs in [tokens].
  Postings _tokensToPostings(DocId docId, Iterable<Token> tokens) {
    // initialize a Postings collection to hold the postings
    final Postings postings = {};
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
  /// - loads the existing [PostingsEntry]s for the terms from the [index]
  ///   [Postings];
  /// - loads the existing [DictionaryEntry]s for the terms from the [index];
  /// - iterates through the [event] entries and:
  /// - inserts or updates each [DocumentPostingsEntry] instance to the index
  ///   [Postings];
  /// - if a [DocumentPostingsEntry] instance did not exist previously,
  ///   increments the document frequency of the associated term;
  /// - then:
  /// - asynchronously updates the index [Dictionary]; and
  /// - asynchronously updates the index [Postings].
  @override
  @mustCallSuper
  Future<void> updateIndexes(Postings event, Iterable<Token> tokens) async {
    // - maps [event] to a set of unique terms;
    final terms = Set<Term>.from(event.keys);
    await _upsertKgrams(tokens);

    // - loads the existing [PostingsEntry]s for the terms from a [Postings] by calling [getPostings];
    final postingsToUpdate = await index.getPostings(terms);
// - loads the existing [DictionaryEntry]s for the terms from a [Dictionary] by calling [getDictionary];
    final Dictionary termsToUpdate = await index.getDictionary(terms);
    // - iterates through the [DocumentPostingsEntry] in [event];
    await Future.forEach(event.entries, (PostingsEntry entry) {
      final term = entry.key;
      final postings = entry.value;
      for (final docEntry in postings.entries) {
        final docId = docEntry.key;
        final fieldPostings = docEntry.value;
        // - inserts or updates each [DocumentPostingsEntry] instance to a collection of postings to update;
        final increment =
            postingsToUpdate.addZonePostings(term, docId, fieldPostings);
        // - if a [DocumentPostingsEntry] instance did not exist previously, also increments the document frequency of the associated term;
        if (increment) {
          termsToUpdate.incrementFrequency(term);
        }
      }
    });
    // - asynchronously updates the [Dictionary] by calling [upsertDictionary];
    await index.upsertDictionary(termsToUpdate);
    // - asynchronously updates the [Postings] by calling [upsertPostings]; and
    await index.upsertPostings(postingsToUpdate);
  }
}

class _TextIndexerImpl extends TextIndexerBase {
  //

  @override
  final InvertedIndex index;

  _TextIndexerImpl(this.index, this.collectionStream, this.documentStream);

  @override
  final Stream<Map<DocId, JSON>>? collectionStream;

  @override
  final Stream<MapEntry<DocId, JSON>>? documentStream;
}
