// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'dart:async';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:text_indexing/text_indexing.dart';

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
/// artifacts using the [loadTerms], [updateDictionary], [loadTermPostings] and
/// [upsertTermPostings] asynchronous methods.
///
/// The [index] method indexes a text document, returning a list of
/// [PostingsMap] that is also emitted by [postingsStream]. The [index] method
/// implementation calls [emit], passing the list of [PostingsMap].
///
/// The [emit] method is called by [index], and adds an event to the
/// [postingsStream].
///
/// Listen to [postingsStream] to update your term dictionary and postings map.
///
/// Implementing classes override the following fields:
/// - [tokenizer] is the [Tokenizer] instance used by the indexer to parse
///   text to tokens;
/// - [postingsStream] emits a list of [PostingsMap] instances whenever a
///   document is indexed.
///
/// Implementing classes override the following asynchronous methods:
/// - [index] indexes a text document, returning a list of [PostingsMap] and
///   adding it to the [postingsStream] by calling [emit];
/// - [emit] is called by [index], and adds an event to the [postingsStream]
///   after updating the [Dictionary] and [Postings];
/// - [loadTerms] returns a [Dictionary] for a vocabulary from
///   a [Dictionary];
/// - [updateDictionary] passes new or updated [DictionaryEntry] instances for persisting
///   to a [Dictionary];
/// - [loadTermPostings] returns [PostingsEntry] entities for a collection
///   of terms from a [Postings]; and
/// - [upsertTermPostings] passes new or updated [PostingsEntry] instances
///   for upserting to a [Postings].
abstract class TextIndexer {
  //

  /// Emits a list of [PostingsMap] instances whenever a document is indexed.
  ///
  /// Listen to [postingsStream] to update your term dictionary and postings
  /// map.
  Stream<List<PostingsMap>> get postingsStream;

  /// The [Tokenizer] used by the indexer to parse documents to tokens.
  Tokenizer get tokenizer;

  /// The [JsonTokenizer] used by the indexer to parse documents to tokens from
  /// the fields in a JSON document.
  JsonTokenizer get jsonTokenizer;

  /// A [Tokenizer] that tokenizes English language text.
  static Future<List<Token>> kDefaultTokenizer(String source,
          [String? field]) async =>
      (await TextAnalyzer().tokenize(source, field)).tokens;

  /// A [Tokenizer] that tokenizes English language text.
  static Future<List<Token>> kDefaultJsonTokenizer(
          Map<String, dynamic> json, List<String> fields) async =>
      (await TextAnalyzer().tokenizeJson(json, fields)).tokens;

  /// The [emit] method is called by [index] and adds the [event] to the
  /// [postingsStream].
  ///
  /// Sub-classes override [emit] to perform additional actions whenever a
  /// document is indexed.
  Future<void> emit(List<PostingsMap> event);

  /// Indexes a text document, returning a list of [PostingsMap].
  ///
  /// Adds the list of [PostingsMap] to the [postingsStream] by calling
  /// [emit].
  FutureOr<List<PostingsMap>> index(String docId, String docText);

  /// Indexes the [fields] in a [json] document, returning a list of
  /// [PostingsMap].
  ///
  /// Adds the list of [PostingsMap] to the [postingsStream] by calling
  /// [emit].
  FutureOr<List<PostingsMap>> indexJson(
      String docId, Map<String, dynamic> json, List<String> fields);

  /// Asynchronously retrieves a [Dictionary] for [terms] from a
  /// [Dictionary] data source.
  Future<Dictionary> loadTerms(Iterable<String> terms);

  /// A callback that passes new or updated [values] for persisting to a
  /// [Dictionary].
  Future<void> updateDictionary(Dictionary values);

  /// Asynchronously retrieves [PostingsEntry] entities for [terms] from a
  /// [Postings].
  Future<Postings> loadTermPostings(Iterable<String> terms);

  /// A callback that passes new or updated [values] for upserting to a
  /// [Postings].
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
/// [tokenizer], before mapping the tokens to a list of [PostingsMap] that is
/// passed to [emit].
///
/// The [emit] method implementation is called by [index], and:
/// - asynchronously updates the [Dictionary] by calling [updateDictionary];
/// - asynchronously updates the [Postings] by calling [upsertTermPostings];
/// - adds an event to the [postingsStream].
///
/// Sub-classes must implement the [tokenizer] field to parse documents to
/// tokens.
///
/// Sub-classes must implement the[loadTerms], [updateDictionary],
/// [loadTermPostings] and [upsertTermPostings] asynchronous methods, used by
/// the [TextIndexerBase] to read and write to/from a [Dictionary] and a
/// [Postings].
abstract class TextIndexerBase implements TextIndexer {
  //

  /// The private stream controller for the [postingsStream].
  final _postingsStreamController = BehaviorSubject<List<PostingsMap>>();

  /// Implementation of [TextIndexer.index] that:
  /// - parses [docText] to a collection of [Token]s;
  /// - maps the tokens to postings for [docId];
  /// - maps the postings for [docId] to a list of [PostingsMap];
  /// - calls [emit], passing the list of [PostingsMap] for [docId]; and
  /// - returns the list of [PostingsMap] for [docId].
  @override
  FutureOr<List<PostingsMap>> index(String docId, String docText) async {
    // get the terms using tokenizer
    final tokens = (await tokenizer(docText));
    // map the tokens to postings
    final Postings postings = _tokensToPostings(docId, tokens);
    // map postings to a list of PostingsMap for docId.
    final event = _postingsToTermPositions(docId, postings);
    // emit the postings list for docId
    await emit(event);
    return event;
  }

  /// Implementation of [TextIndexer.index] that:
  /// - parses [docText] to a collection of [Token]s;
  /// - maps the tokens to postings for [docId];
  /// - maps the postings for [docId] to a list of [PostingsMap];
  /// - calls [emit], passing the list of [PostingsMap] for [docId]; and
  /// - returns the list of [PostingsMap] for [docId].
  @override
  FutureOr<List<PostingsMap>> indexJson(
      String docId, Map<String, dynamic> json, List<String> fields) async {
    // get the terms using tokenizer
    final tokens = (await jsonTokenizer(json, fields));
    // map the tokens to postings
    final Postings postings = _tokensToPostings(docId, tokens);
    // map postings to a list of PostingsMap for docId.
    final event = _postingsToTermPositions(docId, postings);
    // emit the postings list for docId
    await emit(event);
    return event;
  }

  /// Maps [postings] to a list of [PostingsMap] for [docId].
  List<PostingsMap> _postingsToTermPositions(String docId, Postings postings) {
    // initialize the list of PostingsMap that will be emitted
    final event = <PostingsMap>[];
    // iterate through postings.entries
    for (final entry in postings.entries) {
      // shortcut to the term
      final term = entry.key;
      // get the posting for docId and term
      final positions = entry.value[docId];
      if (positions != null) {
        // add a PostingsMap instance for docId and term to event
        event.add(PostingsMap(term, docId, positions));
      }
    }
    return event;
  }

  /// Maps the [tokens] to a [Postings].
  Postings _tokensToPostings(String docId, Iterable<Token> tokens) {
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
  /// - iterates through the [PostingsMap] in [event] and:
  /// - inserts or updates each [PostingsMap] instance to a collection of
  ///   postings to update;
  /// - if a [PostingsMap] instance did not exist previously, increments
  ///   the document frequency of the associated term;
  /// - then:
  /// - asynchronously updates the [Dictionary] by calling
  ///   [updateDictionary];
  /// - asynchronously updates the [Postings] by calling
  ///   [upsertTermPostings]; and
  /// - adds the [event] to the [_postingsStreamController] sink.
  @override
  @mustCallSuper
  Future<void> emit(List<PostingsMap> event) async {
    // - maps [event] to a set of unique terms;
    final terms = Set<String>.from(event.map((e) => e.term));
    // - loads the existing [PostingsEntry]s for the terms from a [Postings] by calling [loadTermPostings];
    final postingsToUpdate = await loadTermPostings(terms);
// - loads the existing [DictionaryEntry]s for the terms from a [Dictionary] by calling [loadTerms];
    final Dictionary termsToUpdate = await loadTerms(terms);
    // - iterates through the [PostingsMap] in [event];
    await Future.forEach(event, (PostingsMap e) {
      // - inserts or updates each [PostingsMap] instance to a collection of postings to update;
      final increment =
          postingsToUpdate.addTermPositions(e.term, e.docId, e.fieldPositions);
      // - if a [PostingsMap] instance did not exist previously, also increments the document frequency of the associated term;
      if (increment) {
        termsToUpdate.incrementFrequency(e.term);
      }
    });
    // - asynchronously updates the [Dictionary] by calling [updateDictionary];
    await updateDictionary(termsToUpdate);
    // - asynchronously updates the [Postings] by calling [upsertTermPostings]; and
    await upsertTermPostings(postingsToUpdate);
    // - adds the [event] to the [_postingsStreamController] sink.
    _postingsStreamController.sink.add(event);
  }

  /// Implements [TextIndexer.postingsStream].
  ///
  /// Returns [_postingsStreamController] stream.
  @override
  Stream<List<PostingsMap>> get postingsStream =>
      _postingsStreamController.stream;
}
