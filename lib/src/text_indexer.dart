// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:async';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:text_indexing/text_indexing.dart';

/// Alias for Map<String, dynamic>, a hashmap known as "Java Script Object
/// Notation" (JSON), a common format for persisting data.
typedef JSON = Map<FieldName, dynamic>;

/// Alias for Map<String, Map<String, dynamic>>, a hashmap of [DocId] to [JSON]
/// documents.
typedef JsonCollection = Map<DocId, JSON>;

/// Interface for classes that construct and maintain an inverted text index.
///
/// The inverted index is comprised of two artifacts:
/// - a [Dictionary] is a hashmap of [DictionaryEntry]s with the vocabulary as
///   key and the document frequency as the values; and
/// - a [Postings] a hashmap of [PostingsEntry]s with the vocabulary as key
///   and the postings lists for the linked documents as values.
///
/// The [Dictionary] and [Postings] can be asynchronous data sources or
/// in-memory hashmaps.  The [TextIndexer] reads and writes to/from these
/// artifacts using the [loadTerms], [upsertDictionary], [loadTermPostings] and
/// [upsertTermPostings] asynchronous methods.
///
/// The [index] method indexes a text document, returning a list of
/// [DocumentPostingsEntry] that is also emitted by [postingsStream]. The [index] method
/// implementation calls [emit], passing the list of [DocumentPostingsEntry].
///
/// The [emit] method is called by [index], and adds an event to the
/// [postingsStream].
///
/// Listen to [postingsStream] to update your term dictionary and postings map.
///
/// Implementing classes override the following fields:
/// - [tokenizer] is the [Tokenizer] instance used by the indexer to parse
///   text to tokens;
/// - [postingsStream] emits a list of [DocumentPostingsEntry] instances whenever a
///   document is indexed.
///
/// Implementing classes override the following asynchronous methods:
/// - [index] indexes a text document, returning a list of [DocumentPostingsEntry] and
///   adding it to the [postingsStream] by calling [emit];
/// - [emit] is called by [index], and adds an event to the [postingsStream]
///   after updating the [Dictionary] and [Postings];
/// - [loadTerms] returns a [Dictionary] for a vocabulary from
///   a [Dictionary];
/// - [upsertDictionary] passes new or updated [DictionaryEntry] instances for persisting
///   to a [Dictionary];
/// - [loadTermPostings] returns [PostingsEntry] entities for a collection
///   of terms from a [Postings]; and
/// - [upsertTermPostings] passes new or updated [PostingsEntry] instances
///   for upserting to a [Postings].
abstract class TextIndexer {
  //

  /// Emits [Postings] hashmap for an indexed document when it is indexed.
  ///
  /// Listen to [postingsStream] to update your term dictionary and postings
  /// map.
  Stream<Postings> get postingsStream;

  /// The [Tokenizer] used by the indexer to parse documents to tokens.
  Tokenizer get tokenizer;

  /// The [JsonTokenizer] used by the indexer to parse documents to tokens from
  /// the fields in a JSON document.
  JsonTokenizer get jsonTokenizer;

  /// A [Tokenizer] that tokenizes English language text.
  static Future<List<Token>> kDefaultTokenizer(SourceText source,
          [FieldName? field]) async =>
      (await TextAnalyzer().tokenize(source, field)).tokens;

  /// A [Tokenizer] that tokenizes English language text.
  static Future<List<Token>> kDefaultJsonTokenizer(
          JSON json, List<FieldName> fields) async =>
      (await TextAnalyzer().tokenizeJson(json, fields)).tokens;

  /// The [emit] method is called by [index] and adds the [event] to the
  /// [postingsStream].
  ///
  /// Sub-classes override [emit] to perform additional actions whenever a
  /// document is indexed.
  Future<void> emit(Postings event);

  /// Indexes a text document, returning a list of [DocumentPostingsEntry].
  ///
  /// Adds [Postings] for [docText] to the [postingsStream].
  Future<Postings> indexText(DocId docId, SourceText docText);

  /// Indexes the [fields] in a [json] document, returning a list of
  /// [DocumentPostingsEntry].
  ///
  /// Adds [Postings] for [json] to the [postingsStream].
  Future<Postings> indexJson(DocId docId, JSON json, List<FieldName> fields);

  /// Indexes the [fields] of all the documents in [collection], adding
  /// [Postings] to the [postingsStream] for each document.
  Future<void> indexCollection(
      JsonCollection collection, List<FieldName> fields);

  /// The [InvertedPositionalZoneIndex] repository that provides access to the
  /// index [Dictionary] and [Postings].
  InvertedPositionalZoneIndex get index;

  /// Asynchronously retrieves a [Dictionary] for [terms] from a
  /// [Dictionary] data source.
  @Deprecated(
      'Method `TextIndexer.loadTerms` is deprecated. Use `TextIndexer.index.getDictionary` instead.')
  Future<Dictionary> loadTerms(Iterable<Term> terms);

  /// A callback that passes new or updated [values] for persisting to a
  /// [Dictionary].
  @Deprecated(
      'Method `TextIndexer.upsertDictionary` is deprecated. Use `TextIndexer.index.upsertDictionary` instead.')
  Future<void> upsertDictionary(Dictionary values);

  /// Asynchronously retrieves [PostingsEntry] entities for [terms] from a
  /// [Postings].
  @Deprecated(
      'Method `TextIndexer.loadTermPostings` is deprecated. Use `TextIndexer.index.getPostings` instead.')
  Future<Postings> loadTermPostings(Iterable<Term> terms);

  /// A callback that passes new or updated [values] for upserting to a
  /// [Postings].
  @Deprecated(
      'Method `TextIndexer.upsertTermPostings` is deprecated. Use `TextIndexer.index.upsertPostings` instead.')
  Future<void> upsertTermPostings(Postings values);

  //
}

/// Base class implementation of the [TextIndexer] interface that constructs and
/// maintains an inverted index consisting of a [Dictionary] and [Postings].
///
/// The [Dictionary] and [Postings] can be asynchronous data sources or
/// in-memory hashmaps.
///
/// The [index] method implementation tokenizes a text document using
/// [tokenizer], before mapping the tokens to a list of [DocumentPostingsEntry] that is
/// passed to [emit].
///
/// The [emit] method implementation is called by [index], and:
/// - asynchronously updates the [Dictionary] by calling [upsertDictionary];
/// - asynchronously updates the [Postings] by calling [upsertTermPostings];
/// - adds an event to the [postingsStream].
///
/// Sub-classes must implement the [tokenizer] field to parse documents to
/// tokens.
///
/// Sub-classes must implement the[loadTerms], [upsertDictionary],
/// [loadTermPostings] and [upsertTermPostings] asynchronous methods, used by
/// the [TextIndexerBase] to read and write to/from a [Dictionary] and a
/// [Postings].
abstract class TextIndexerBase implements TextIndexer {
  //

  /// Implementation of [TextIndexer.upsertDictionary].
  ///
  /// Calls the [index.upsertDictionary] callback function.
  @override
  Future<void> upsertDictionary(Dictionary values) =>
      index.upsertDictionary(values);

  /// Implementation of [TextIndexer.loadTermPostings].
  ///
  /// Calls the [index.getPostings] callback function.
  @override
  Future<Postings> loadTermPostings(Iterable<String> terms) =>
      index.getPostings(terms);

  /// Implementation of [TextIndexer.upsertTermPostings].
  ///
  /// Calls the [index.upsertPostings] callback function.
  @override
  Future<void> upsertTermPostings(Postings values) =>
      index.upsertPostings(values);

  /// Implementation of [TextIndexer.loadTerms].
  ///
  /// Calls the [ndex.getDictionary] callback function.
  @override
  Future<Dictionary> loadTerms(Iterable<String> terms) =>
      index.getDictionary(terms);

  /// The private stream controller for the [postingsStream].
  final _postingsStreamController = BehaviorSubject<Postings>();

  /// Implementation of [TextIndexer.index] that:
  /// - parses [docText] to a collection of [Token]s;
  /// - maps the tokens to postings for [docId];
  /// - maps the postings for [docId] to a list of [DocumentPostingsEntry];
  /// - calls [emit], passing the list of [DocumentPostingsEntry] for [docId]; and
  /// - returns the list of [DocumentPostingsEntry] for [docId].
  @override
  Future<Postings> indexText(DocId docId, SourceText docText) async {
    // get the terms using tokenizer
    final tokens = (await tokenizer(docText));
    // map the tokens to postings
    final Postings postings = _tokensToPostings(docId, tokens);
    // map postings to a list of DocumentPostingsEntry for docId.
    // final event = _postingsToTermPositions(docId, postings);
    // emit the postings list for docId
    await emit(postings);
    return postings;
  }

  /// Implementation of [TextIndexer.index] that:
  /// - parses [docText] to a collection of [Token]s;
  /// - maps the tokens to postings for [docId];
  /// - maps the postings for [docId] to a list of [DocumentPostingsEntry];
  /// - calls [emit], passing the list of [DocumentPostingsEntry] for [docId]; and
  /// - returns the list of [DocumentPostingsEntry] for [docId].
  @override
  Future<Postings> indexJson(
      DocId docId, JSON json, List<FieldName> fields) async {
    // get the terms using tokenizer
    final tokens = (await jsonTokenizer(json, fields));
    // map the tokens to postings
    final Postings postings = _tokensToPostings(docId, tokens);
    // map postings to a list of DocumentPostingsEntry for docId.
    // final event = _postingsToTermPositions(docId, postings);
    // emit the postings list for docId
    await emit(postings);
    return postings;
  }

  @override
  Future<void> indexCollection(
      JsonCollection collection, List<FieldName> fields) async {
    await Future.forEach(collection.entries, (MapEntry<DocId, JSON> e) async {
      final docId = e.key;
      final json = e.value;
      await indexJson(docId, json, fields);
    });
  }

  /// Maps the [tokens] to a [Postings].
  Postings _tokensToPostings(DocId docId, Iterable<Token> tokens) {
    // initialize a Postings collection to hold the postings
    final Postings postings = {};
    // initialize the term position index
    for (var token in tokens) {
      // add a term position to postings
      postings.addTermPosition(
          term: token.term,
          docId: docId,
          field: token.field,
          position: token.termPosition);
    }
    return postings;
  }

  /// Implementation of [TextIndexer.emit] that:
  /// - maps [event] to a set of unique terms;
  /// - loads the existing [PostingsEntry]s for the terms from a
  ///   [Postings] by calling [loadTermPostings];
  /// - loads the existing [DictionaryEntry]s for the terms from a [Dictionary] by
  ///   calling [loadTerms];
  /// - iterates through the [DocumentPostingsEntry] in [event] and:
  /// - inserts or updates each [DocumentPostingsEntry] instance to a collection of
  ///   postings to update;
  /// - if a [DocumentPostingsEntry] instance did not exist previously, increments
  ///   the document frequency of the associated term;
  /// - then:
  /// - asynchronously updates the [Dictionary] by calling
  ///   [upsertDictionary];
  /// - asynchronously updates the [Postings] by calling
  ///   [upsertTermPostings]; and
  /// - adds the [event] to the [_postingsStreamController] sink.
  @override
  @mustCallSuper
  Future<void> emit(Postings event) async {
    // - maps [event] to a set of unique terms;
    final terms = Set<Term>.from(event.keys);
    // - loads the existing [PostingsEntry]s for the terms from a [Postings] by calling [loadTermPostings];
    final postingsToUpdate = await loadTermPostings(terms);
// - loads the existing [DictionaryEntry]s for the terms from a [Dictionary] by calling [loadTerms];
    final Dictionary termsToUpdate = await loadTerms(terms);
    // - iterates through the [DocumentPostingsEntry] in [event];
    await Future.forEach(event.entries, (PostingsEntry entry) {
      final term = entry.key;
      final postings = entry.value;
      for (final docEntry in postings.entries) {
        final docId = docEntry.key;
        final fieldPostings = docEntry.value;
        // - inserts or updates each [DocumentPostingsEntry] instance to a collection of postings to update;
        final increment =
            postingsToUpdate.addFieldPostings(term, docId, fieldPostings);
        // - if a [DocumentPostingsEntry] instance did not exist previously, also increments the document frequency of the associated term;
        if (increment) {
          termsToUpdate.incrementFrequency(term);
        }
      }
    });
    // - asynchronously updates the [Dictionary] by calling [upsertDictionary];
    await upsertDictionary(termsToUpdate);
    // - asynchronously updates the [Postings] by calling [upsertTermPostings]; and
    await upsertTermPostings(postingsToUpdate);
    // - adds the [event] to the [_postingsStreamController] sink.
    _postingsStreamController.sink.add(event);
  }

  /// Implements [TextIndexer.postingsStream].
  ///
  /// Returns [_postingsStreamController] stream.
  @override
  Stream<Postings> get postingsStream => _postingsStreamController.stream;
}
