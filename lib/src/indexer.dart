// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'dart:async';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:text_analysis/text_analysis.dart';
import 'package:text_indexing/text_indexing.dart';

/// Base class for classes that construct and maintain an inverted index:
/// - [tokenizer] is the [Tokenizer] instance used by the indexer to parse
///   documents to tokens;
/// - the [index] method indexes documents one-by-one, adding a list of
///   [TermPositions] to the [postingsStream] for each document;
/// - listen to [postingsStream] to update your term dictionary and postings
///   map; and/or
/// - override [emit] to perform additional actions whenever a
///   document is indexed, e.g. updating a term dictionary of postings list.
abstract class Indexer {
  //

  // /// Instantiates a [Indexer].
  // ///
  // /// Calls [init] to asynchronously load the [dictionary] into memory.
  // Indexer(this.dictionary);

  /// Asynchronously retrieves a [TermDictionary] for [terms] from a
  /// [TermDictionary] data source, usually persisted storage.
  Future<TermDictionary> loadTerms(Iterable<String> terms);

  /// A callback that passes a collection of [Term] instances for persisting to
  /// the [TermDictionary] datastore.
  Future<void> updateDictionary(TermDictionary terms);

  /// Asynchronously retrieves [PostingsMapEntry] entities for [terms] from a
  /// [PostingsMap] data source, usually persisted storage.
  Future<PostingsMap> loadTermPostings(Iterable<String> terms);

  /// A callback that passes a collection of [PostingsMapEntry] instances for
  /// persisting to the [PostingsMap] datastore.
  Future<void> upsertTermPostings(PostingsMap postings);

  /// The private stream controller for the [postingsStream].
  final _postingsStreamController = BehaviorSubject<List<TermPositions>>();

  /// A [Tokenizer] that tokenizes English language text.
  static Future<List<Token>> kDefaultTokenizer(String source) async =>
      (await TextAnalyzer().tokenize(source)).tokens;

  /// The [Tokenizer] used by the indexer to parse documents to tokens.
  Tokenizer get tokenizer;

  /// Parses the [docText] into a collection of [TermPositions] using the
  /// [tokenizer].
  ///
  /// Adds the collection of [TermPositions] for the document to the
  /// [postingsStream] by calling [emit].
  FutureOr<void> index(String docId, String docText) async {
    // get the terms using tokenizer
    final terms = (await tokenizer(docText)).map((e) => e.term).toList();
    // initialize a PostingsMap collection to hold the postings
    final PostingsMap postings = {};
    // initialize the term position index
    var position = 0;
    for (var term in terms) {
      // add a term position to postings
      postings.addTermPosition(term, docId, position);
      // increment the term position index
      position++;
    }
    // initialize the list of TermPositions that will be emitted
    final event = <TermPositions>[];
    // iterate through postings.entries
    for (final entry in postings.entries) {
      // shortcut to the term
      final term = entry.key;
      // get the posting for docId and term
      final positions = entry.value[docId];
      if (positions != null) {
        // add a TermPositions instance for docId and term to event
        event.add(TermPositions(term, docId, positions));
      }
    }
    // emit the posting for docId
    await emit(event);
  }

  /// The [emit] method is called by [index] and adds the [event] to the
  /// [_postingsStreamController] sink.
  ///
  /// Sub-classes override [emit] to perform additional actions whenever a
  /// document is indexed.
  @mustCallSuper
  Future<void> emit(List<TermPositions> event) async {
    final terms = event.map((e) => e.term);
    final postings = await loadTermPostings(terms);
    final TermDictionary termsToUpdate = await loadTerms(terms);
    await Future.forEach(event, (TermPositions e) {
      final increment = postings.addTermPositions(e.term, e.docId, e.positions);
      if (increment) {
        // dictionary.incrementFrequency(e.term);
        termsToUpdate.incrementFrequency(e.term);
      }
    });
    await updateDictionary(termsToUpdate);
    await upsertTermPostings(postings);
    _postingsStreamController.sink.add(event);
  }

  /// Emits a list of [TermPositions] instances whenever a document is indexed.
  ///
  /// Listen to [postingsStream] to update your term dictionary and postings
  /// map.
  Stream<List<TermPositions>> get postingsStream =>
      _postingsStreamController.stream;
}
