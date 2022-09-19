// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'dart:async';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
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
/// Implementing classes override the following fields:
/// - [index] is the [InvertedIndex] that provides access to the
///   index [Dictionary] and [Postings] and a [ITextAnalyzer];
/// - [postingsStream] emits a [Postings] whenever a
///   document is indexed.
///
/// Implementing classes override the following asynchronous methods:
/// - [indexText] indexes a text document;
/// - [indexJson] indexes the fields in a JSON document;
/// - [indexCollection] indexes the fields of all the documents in JSON
///   document collection; and
/// - [emit] adds an event to the [postingsStream] after updating the [index];
abstract class TextIndexer {
  //

  /// A const constructor for sub classes
  const TextIndexer();

  /// Factory constructor returns a [TextIndexer] instance with in-memory
  /// [Dictionary] and [Postings] maps:
  /// - pass a [analyzer] text analyser that extracts tokens from text;
  /// - pass an in-memory [dictionary] instance, otherwise an empty
  ///   [Dictionary] will be initialized.
  /// - pass an in-memory [postings] instance, otherwise an empty [Postings]
  ///   will be initialized.
  factory TextIndexer.inMemory(
          {Dictionary? dictionary,
          Postings? postings,
          ITextAnalyzer analyzer = const TextAnalyzer()}) =>
      _TextIndexerImpl(InMemoryIndex(
          dictionary: dictionary ?? {},
          postings: postings ?? {},
          analyzer: analyzer));

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
  ///   from a data source; and
  /// - [postingsUpdater] passes a [Postings] subset for persisting to a
  ///   datastore.
  factory TextIndexer.async(
          {required DictionaryLoader dictionaryLoader,
          required DictionaryLengthLoader dictionaryLengthLoader,
          required DictionaryUpdater dictionaryUpdater,
          required PostingsLoader postingsLoader,
          required PostingsUpdater postingsUpdater,
          ITextAnalyzer analyzer = const TextAnalyzer()}) =>
      _TextIndexerImpl(AsyncCallbackIndex(
          dictionaryLoader: dictionaryLoader,
          dictionaryLengthLoader: dictionaryLengthLoader,
          dictionaryUpdater: dictionaryUpdater,
          postingsLoader: postingsLoader,
          postingsUpdater: postingsUpdater,
          analyzer: analyzer));

  /// Factory constructor initializes a [TextIndexer] instance, passing in a
  /// [index] instance.
  factory TextIndexer.index({
    required InvertedIndex index,
    // Tokenizer tokenizer = TextIndexer.kDefaultTokenizer,
    // JsonTokenizer jsonTokenizer = TextIndexer.kDefaultJsonTokenizer
  }) =>
      _TextIndexerImpl(index);

  /// Emits [Postings] hashmap for an indexed document when it is indexed.
  ///
  /// Listen to [postingsStream] to update your term dictionary and postings
  /// map.
  Stream<Postings> get postingsStream;

  /// The [emit] method is called by [index] and adds the [event] to the
  /// [postingsStream].
  ///
  /// Sub-classes override [emit] to perform additional actions whenever a
  /// document is indexed.
  Future<void> emit(Postings event);

  /// Indexes a text document, returning a [Postings].
  ///
  /// Adds [Postings] for [docText] to the [postingsStream].
  Future<Postings> indexText(DocId docId, SourceText docText);

  /// Indexes the [fields] in a [json] document, returning a list of
  /// [DocumentPostingsEntry].
  ///
  /// Adds [Postings] for [json] to the [postingsStream].
  Future<Postings> indexJson(DocId docId, JSON json, List<Zone> fields);

  /// Indexes the [fields] of all the documents in [collection], adding
  /// [Postings] to the [postingsStream] for each document.
  Future<void> indexCollection(JsonCollection collection, List<Zone> fields);

  /// The [InvertedIndex] that provides access to the
  /// index [Dictionary] and [Postings] and a [ITextAnalyzer].
  InvertedIndex get index;

  //
}

/// Base class implementation of the [TextIndexer] interface.
///
/// Uses a [BehaviorSubject] as stream [controller] for [postingsStream].
///
/// Sub-classes must implement the [index] and [controller] fields
abstract class TextIndexerBase implements TextIndexer {
  //

  /// A const default constructor for classes that extend [TextIndexerBase].
  const TextIndexerBase();

  /// The private stream controller for the [postingsStream].
  BehaviorSubject<Postings> get controller;

  /// Implementation of [TextIndexer.indexText] that:
  /// - parses [docText] to a collection of [Token]s;
  /// - maps the tokens to postings for [docId];
  /// - maps the postings for [docId] to a [Postings];
  /// - calls [emit], passing the [Postings] for [docId]; and
  /// - returns the [Postings] for [docId].
  @override
  Future<Postings> indexText(DocId docId, SourceText docText) async {
    // get the terms using tokenizer
    final tokens = (await index.analyzer.tokenize(docText)).tokens;
    // map the tokens to postings
    final Postings postings = _tokensToPostings(docId, tokens);
    // map postings to a list of DocumentPostingsEntry for docId.
    // final event = _postingsToTermPositions(docId, postings);
    // emit the postings list for docId
    await emit(postings);
    return postings;
  }

  /// Implementation of [TextIndexer.indexJson] that:
  /// - parses [json] to a collection of [Token]s;
  /// - maps the tokens to postings for [docId];
  /// - maps the postings for [docId] to a [Postings];
  /// - calls [emit], passing the [Postings] for [docId]; and
  /// - returns the [Postings] for [docId].
  @override
  Future<Postings> indexJson(DocId docId, JSON json, List<Zone> fields) async {
    // get the terms using tokenizer
    final tokens = (await index.analyzer.tokenizeJson(json, fields)).tokens;
    // map the tokens to postings
    final Postings postings = _tokensToPostings(docId, tokens);
    // map postings to a list of DocumentPostingsEntry for docId.
    // final event = _postingsToTermPositions(docId, postings);
    // emit the postings list for docId
    await emit(postings);
    return postings;
  }

  /// Implementation of [TextIndexer.indexCollection] that parses each JSON
  /// document in [collection] to [Token]s and maps the tokens to a [Postings]
  /// that is passed to [emit].
  @override
  Future<void> indexCollection(
      JsonCollection collection, List<Zone> fields) async {
    await Future.forEach(collection.entries, (MapEntry<DocId, JSON> e) async {
      final docId = e.key;
      final json = e.value;
      await indexJson(docId, json, fields);
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
    Term term1 = '';
    for (var token in tokens) {
      final term2 = token.term;
      if (term2.isNotEmpty) {
        // add a term position to postings
        postings.addTermPosition(
            term: term2,
            docId: docId,
            zone: token.zone,
            position: token.termPosition);
        if (term1.isNotEmpty) {
          final termPair = TermPair(term1, term2);
          // add the term
          postings.addTermPosition(
              term: termPair.toString(),
              docId: docId,
              zone: token.zone,
              position: token.termPosition);
        }
        term1 = term2;
      }
    }
    return postings;
  }

  /// Implementation of [TextIndexer.emit] that:
  /// - maps [event] to a set of unique terms;
  /// - loads the existing [PostingsEntry]s for the terms from the [index]
  ///   [Postings];
  /// - loads the existing [DictionaryEntry]s for the terms from the [index];
  /// - iterates through the [event] entries and:
  /// - inserts or updates each [DocumentPostingsEntry] instance to the index
  ///   [Postings];
  /// - if a [DocumentPostingsEntry] instance did not exist previously, increments
  ///   the document frequency of the associated term;
  /// - then:
  /// - asynchronously updates the index [Dictionary];
  /// - asynchronously updates the index [Postings]; and
  /// - adds the [event] to the [controller] sink.
  @override
  @mustCallSuper
  Future<void> emit(Postings event) async {
    // - maps [event] to a set of unique terms;
    final terms = Set<Term>.from(event.keys);
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
    // - adds the [event] to the [controller] sink.
    controller.sink.add(event);
  }

  /// Implements [TextIndexer.postingsStream].
  ///
  /// Returns [controller].stream.
  @override
  Stream<Postings> get postingsStream => controller.stream;
}

class _TextIndexerImpl extends TextIndexerBase {
  //

  @override
  final InvertedIndex index;

  @override
  final controller = BehaviorSubject<Postings>();

  _TextIndexerImpl(this.index);
}
