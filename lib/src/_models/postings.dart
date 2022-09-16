// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/text_indexing.dart';

/// Type definition for a hashmap of [Term] to [DocumentPostings].
typedef Postings = Map<Term, DocumentPostings>;

/// Type definition for a hashmap entry of [Term] to [DocumentPostings] in a
/// [Postings] hashmap.
typedef PostingsEntry = MapEntry<Term, DocumentPostings>;

/// An alias for [int], used to denote the position of a [Term] in [SourceText]
/// indexed object (the term position).
typedef Pt = int;

/// An alias for [String], used whenever a document id is referenced.
typedef DocId = String;

/// Type definition for a hashmap of [DocId] to [FieldPostings].
typedef DocumentPostings = Map<DocId, FieldPostings>;

/// Type definition for a hashmap entry of [DocId] to [FieldPostings] in a
/// [DocumentPostings] hashmap.
typedef DocumentPostingsEntry = MapEntry<DocId, FieldPostings>;

/// Type definition for a hashmap of [FieldName]s to [TermPositions].
typedef FieldPostings = Map<FieldName, TermPositions>;

/// Type definition for a hashmap entry of [FieldName] to [TermPositions] in a
/// [FieldPostings] hashmap.
typedef FieldPostingsEntry = MapEntry<FieldName, TermPositions>;

/// Type definition for an ordered [Set] of unique zero-based term
/// positions in a text source, sorted in ascending order.
typedef TermPositions = List<Pt>;

/// Asynchronously retrieves a [Postings] subset for a collection of
/// [terms] from a [Postings] data source, usually persisted storage.
typedef PostingsLoader = Future<Postings> Function(Iterable<Term> terms);

/// A callback that [values] for persisting to a [Postings].
///
/// Parameter [values] is a subset of a [Postings] containing new or changed
/// [PostingsEntry] instances.
typedef PostingsUpdater = Future<void> Function(Postings values);

/// The [PostingsEntry] class enumerates the properties of an entry in a
/// [Postings] collection:
/// - [term] is the word/term that is indexed; and
/// - [postings] is a hashmap of the [DocumentPostingsEntry] for [term].
extension PostingsEntryExtension on PostingsEntry {
  //

  /// Returns [key], the indexed [Term].
  Term get term => key;

  /// Returns [value], a hashmap of the [DocId] to [FieldPostings].
  DocumentPostings get postings => value;
}

/// The [DocumentPostingsEntry] class enumerates the properties of a document
/// posting in a [Postings] as part of an inverted index of a dataset:
/// - [docId] is the document's id value, (the [DocumentPostingsEntry.key]);
/// - [fieldPostings] is a hashmap of field names that contain the term to
///   the a zero-based, ordered list of word positions of the term in the
///   field (the [DocumentPostingsEntry.value]).
extension DocumentPostingsEntryExtension on DocumentPostingsEntry {
  //
  /// The document's id value.
  ///
  /// Usually the value of the document's primary key field in the dataset.
  DocId get docId => key;

  /// A hashmap of field names that conatin the term to the a zero-based,
  /// ordered list of unique word positions of the [Term] in the field.
  ///
  /// A word position means the index of the word in an array of all the words
  /// in the document.
  FieldPostings get fieldPostings => value;
}

/// Extension methods and properties on [Postings].
extension PostingsExtension on Postings {
  //

  /// Returns all the unique document ids ([DocId]) in the [Postings].
  Set<DocId> get documents {
    final Set<DocId> retVal = {};
    for (final docPostings in values) {
      retVal.addAll(docPostings.keys);
    }
    return retVal;
  }

  /// Filters the [Postings] by [terms], [docIds] AND [fields].
  ///
  /// Filter is applied by succesively calling, in order:
  /// - [getPostings] if [terms] is not null; then
  /// - [documentPostings], if [docIds] is not null; and finally
  /// - [fieldPostings], if [fields] is not null.
  Postings filter(
      {Iterable<Term>? terms,
      Iterable<DocId>? docIds,
      Iterable<FieldName>? fields}) {
    Postings retVal = terms != null ? getPostings(terms) : Postings.from(this);
    retVal = docIds != null ? retVal.documentPostings(docIds) : retVal;
    return fields != null ? retVal.fieldPostings(fields) : retVal;
  }

  /// Filters the [Postings] by terms.
  ///
  /// Returns a subset of the [Postings] instance that only contains
  /// entires with a key in the [terms] collection.
  Postings getPostings(Iterable<Term> terms) {
    final Postings retVal = {};
    for (final term in terms) {
      final posting = this[term];
      if (posting != null) {
        retVal[term] = posting;
      }
    }
    return retVal;
  }

  /// Filters the [Postings] by document ids.
  ///
  /// Returns a subset of the [Postings] instance that only contains entries
  /// where a document id in [docIds] has a key in the entry's postings lists.
  Postings documentPostings(Iterable<DocId> docIds) => Postings.from(this)
    ..removeWhere((key, value) =>
        value.keys.toSet().intersection(docIds.toSet()).isEmpty);

  /// Filters the [Postings] by field names.
  ///
  /// Returns a subset of the [Postings] instance that only contains entries
  /// where a field name in [fields] has a key in any document's postings the
  /// entry's postings lists.
  Postings fieldPostings(Iterable<FieldName> fields) => Postings.from(this)
    ..removeWhere((key, value) {
      final docFields = <FieldName>[];
      for (final doc in value.values) {
        docFields.addAll(doc.keys);
      }
      return docFields.toSet().intersection(fields.toSet()).isEmpty;
    });

  /// Returns the list of all the [DocumentPostingsEntry] for the [terms]
  /// from the [Postings].
  ///
  /// Returns all the [DocumentPostingsEntry] instances for all terms in
  /// the [Postings] if [terms] is null.
  List<DocumentPostingsEntry> termPostingsList([Iterable<Term>? terms]) {
    final List<DocumentPostingsEntry> termPostings = [];
    if (terms != null) {
      for (final term in terms) {
        final entry = this[term];
        if (entry != null) {
          termPostings.addAll(entry.entries);
        }
      }
    } else {
      for (final entry in values) {
        termPostings.addAll(entry.entries);
      }
    }
    return termPostings;
  }

  /// Returns the list of [PostingsEntry] elements in the [Postings] in
  /// alphapetic order of the terms (keys).
  List<PostingsEntry> toList() => entries.toList();

  /// Returns the dictionary terms (keys) as an ordered list,
  /// sorted alphabetically.
  List<Term> get terms {
    final terms = keys.toList();
    terms.sort((a, b) => a.compareTo(b));
    return terms;
  }

  /// Adds a postings for the [docId] to [Postings] entry for the [term].
  ///
  ///   Returns true if  posting positions for the [docId] did not previously
  /// exist in the [Postings].
  ///
  /// Looks up an existing entry for [term] and inserts/overwrites an entry
  /// for [docId] if it exists.
  ///
  /// If no entry for [term] exists in the [Postings], creates a new entry
  /// and adds [positions] for [docId] to the new entry.
  bool addFieldPostings(Term term, DocId docId, FieldPostings positions) {
    //
    // get the entry for the term or initialize a new one if it does not exist
    final DocumentPostings entry = this[term] ?? {};
    // get the existing positions list for [docId] if it exists
    final existingEntry = entry[docId];
    // overwrite the positions for docId
    entry[docId] = positions;
    // set the entry for term with the new positions for docId
    this[term] = entry;
    // return true if a positions list for [docId] did not existed
    return existingEntry == null;
  }

  /// Adds or updates a posting position for the [docId] to [Postings] entry
  /// for the [term].
  ///
  /// Returns true if the posting positions for the [docId] did not previously
  /// exist in the [Postings].
  ///
  /// Looks up an existing entry for [term] and adds a position to the list of
  /// positions for [docId] if it exists.
  ///
  /// If no entry for [term] exists in the [Postings], creates a new entry
  /// for term.
  ///
  /// If no positions list exists for [docId], creates a new position list
  /// for [docId].
  ///
  /// Adds [position] to the positions list for [docId] if it is not already
  /// in the list.
  ///
  /// Sorts the positions list in ascending order.
  ///
  /// Updates the [term] entry in the [Postings].
  bool addTermPosition(
      {required Term term,
      required DocId docId,
      required Pt position,
      FieldName? field}) {
    //
    field = field ?? 'null';
    // get the entry for the term or initialize a new one if it does not exist
    final entry = this[term] ?? {};
    // get the existing field postings for [docId] if it exists
    final docPostings = entry[docId] ?? {};
    // get the existing psitions in the field for [field] if it exists
    final docFieldPostings = docPostings[field];
    // initializes positions set from docFieldPostings or an empty list
    final set = (docFieldPostings ?? []).toSet();
    // add position to the set
    set.add(position);
    // convert to list
    final positions = set.toList();
    // order the list of positions in ascending order
    positions.sort(((a, b) => a.compareTo(b)));
    // set the positions for docId
    docPostings[field] = positions;
    // overwrite the field postings for docId
    entry[docId] = docPostings;

    // set the entry for term with the new positions for docId
    this[term] = entry;
    // return true if a positions list for [docId] did not existed
    return docFieldPostings == null;
  }
}
