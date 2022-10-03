// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/src/_index.dart';

/// The [PostingsMapEntry] class enumerates the properties of an entry in a
/// [PostingsMap] collection:
/// - [term] is the word/term that is indexed; and
/// - [postings] is a hashmap of the [DocPostingsMapEntry] for [term].
extension PostingsEntryExtension on PostingsMapEntry {
  //

  /// Returns [key], the indexed [Term].
  Term get term => key;

  /// Returns [value], a hashmap of the [DocId] to [ZonePostingsMap].
  DocPostingsMap get postings => value;
}

/// The [DocPostingsMapEntry] class enumerates the properties of a document
/// posting in a [PostingsMap] as part of an inverted index of a dataset:
/// - [docId] is the document's id value, (the [DocPostingsMapEntry.key]);
/// - [fieldPostings] is a hashmap of zone names that contain the term to
///   the a zero-based, ordered list of word positions of the term in the
///   zone (the [DocPostingsMapEntry.value]).
extension DocumentPostingsEntryExtension on DocPostingsMapEntry {
  //
  /// The document's id value.
  ///
  /// Usually the value of the document's primary key zone in the dataset.
  DocId get docId => key;

  /// A hashmap of zone names that contain the term to the a zero-based,
  /// ordered list of unique word positions of the [Term] in the zone.
  ///
  /// A word position means the index of the word in an array of all the words
  /// in the document.
  ZonePostingsMap get fieldPostings => value;
}

/// Extension methods and properties on [PostingsMap].
extension PostingsExtension on PostingsMap {
  //

  /// Returns a [Set] of [DocId] of those documents that contain all the
  /// [terms].
  Set<DocId> containsAll(Iterable<Term> terms) {
    final byTerm = getPostings(terms);
    Set<String> intersection = byTerm.docIds;
    for (final docPostings in byTerm.values) {
      intersection = intersection.intersection(docPostings.keys.toSet());
    }
    return intersection;
  }

  /// Returns a [Set] of [DocId] of those documents that contain any of
  /// the [terms]. Used for `index-elimination` as a fist pass in scoring and
  /// ranking of search results.
  Set<DocId> containsAny(Iterable<Term> terms) => getPostings(terms).docIds;

  /// Returns all the unique document ids ([DocId]) in the [PostingsMap].
  Set<DocId> get docIds {
    final Set<DocId> retVal = {};
    for (final docPostings in values) {
      retVal.addAll(docPostings.keys);
    }
    return retVal;
  }

  /// Filters the [PostingsMap] by [terms], [docIds] AND [fields].
  ///
  /// Filter is applied by succesively calling, in order:
  /// - [getPostings] if [terms] is not null; then
  /// - [documentPostings], if [docIds] is not null; and finally
  /// - [fieldPostings], if [fields] is not null.
  PostingsMap filter(
      {Iterable<Term>? terms,
      Iterable<DocId>? docIds,
      Iterable<Zone>? fields}) {
    PostingsMap retVal =
        terms != null ? getPostings(terms) : PostingsMap.from(this);
    retVal = docIds != null ? retVal.documentPostings(docIds) : retVal;
    return fields != null ? retVal.fieldPostings(fields) : retVal;
  }

  /// Filters the [PostingsMap] by terms.
  ///
  /// Returns a subset of the [PostingsMap] instance that only contains
  /// entires with a key in the [terms] collection.
  PostingsMap getPostings(Iterable<Term> terms) {
    final PostingsMap retVal = {};
    for (final term in terms) {
      final posting = this[term];
      if (posting != null) {
        retVal[term] = posting;
      }
    }
    return retVal;
  }

  /// Returns the list of all the [DocPostingsMapEntry] for the [term]
  /// from the [PostingsMap].
  List<DocPostingsMapEntry> termPostings(Term term) =>
      this[term]?.entries.toList() ?? [];

  /// Filters the [PostingsMap] by document ids.
  ///
  /// Returns a subset of the [PostingsMap] instance that only contains entries
  /// where a document id in [docIds] has a key in the entry's postings lists.
  PostingsMap documentPostings(Iterable<DocId> docIds) => PostingsMap.from(this)
    ..removeWhere((key, value) =>
        value.keys.toSet().intersection(docIds.toSet()).isEmpty);

  /// Filters the [PostingsMap] by zone names.
  ///
  /// Returns a subset of the [PostingsMap] instance that only contains entries
  /// where a zone name in [fields] has a key in any document's postings the
  /// entry's postings lists.
  PostingsMap fieldPostings(Iterable<Zone> fields) => PostingsMap.from(this)
    ..removeWhere((key, value) {
      final docFields = <Zone>[];
      for (final doc in value.values) {
        docFields.addAll(doc.keys);
      }
      return docFields.toSet().intersection(fields.toSet()).isEmpty;
    });

  /// Returns the list of all the [DocPostingsMapEntry] for the [terms]
  /// from the [PostingsMap].
  ///
  /// Returns all the [DocPostingsMapEntry] instances for all terms in
  /// the [PostingsMap] if [terms] is null.
  List<DocPostingsMapEntry> termPostingsList([Iterable<Term>? terms]) {
    final List<DocPostingsMapEntry> termPostings = [];
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

  /// Returns the list of [PostingsMapEntry] elements in the [PostingsMap] in
  /// alphapetic order of the terms (keys).
  List<PostingsMapEntry> toList() => entries.toList();

  /// Returns the dictionary terms (keys) as an ordered list,
  /// sorted alphabetically.
  List<Term> get terms {
    final terms = keys.toList();
    terms.sort((a, b) => a.compareTo(b));
    return terms;
  }

  /// Adds a postings for the [docId] to [PostingsMap] entry for the [term].
  ///
  ///   Returns true if  posting positions for the [docId] did not previously
  /// exist in the [PostingsMap].
  ///
  /// Looks up an existing entry for [term] and inserts/overwrites an entry
  /// for [docId] if it exists.
  ///
  /// If no entry for [term] exists in the [PostingsMap], creates a new entry
  /// and adds [positions] for [docId] to the new entry.
  bool addZonePostings(Term term, DocId docId, ZonePostingsMap positions) {
    //
    // get the entry for the term or initialize a new one if it does not exist
    final DocPostingsMap entry = this[term] ?? {};
    // get the existing positions list for [docId] if it exists
    final existingEntry = entry[docId];
    // overwrite the positions for docId
    entry[docId] = positions;
    // set the entry for term with the new positions for docId
    this[term] = entry;
    // return true if a positions list for [docId] did not existed
    return existingEntry == null;
  }

  /// Adds or updates a posting position for the [docId] to [PostingsMap] entry
  /// for the [term].
  ///
  /// Returns true if the posting positions for the [docId] did not previously
  /// exist in the [PostingsMap].
  ///
  /// Looks up an existing entry for [term] and adds a position to the list of
  /// positions for [docId] if it exists.
  ///
  /// If no entry for [term] exists in the [PostingsMap], creates a new entry
  /// for term.
  ///
  /// If [zone] is null, the posting position zone name is "null".
  ///
  /// If no positions list exists for [docId], creates a new position list
  /// for [docId].
  ///
  /// Adds [position] to the positions list for [docId] if it is not already
  /// in the list.
  ///
  /// Sorts the positions list in ascending order.
  ///
  /// Updates the [term] entry in the [PostingsMap].
  bool addTermPosition(
      {required Term term,
      required DocId docId,
      required Pt position,
      Zone? zone}) {
    //
    zone = zone ?? 'null';
    // get the entry for the term or initialize a new one if it does not exist
    final entry = this[term] ?? {};
    // get the existing zone postings for [docId] if it exists
    final docPostings = entry[docId] ?? {};
    // get the existing psitions in the zone for [zone] if it exists
    final docFieldPostings = docPostings[zone];
    // initializes positions set from docFieldPostings or an empty list
    final set = (docFieldPostings ?? []).toSet();
    // add position to the set
    set.add(position);
    // convert to list
    final positions = set.toList();
    // order the list of positions in ascending order
    positions.sort(((a, b) => a.compareTo(b)));
    // set the positions for docId
    docPostings[zone] = positions;
    // overwrite the zone postings for docId
    entry[docId] = docPostings;

    // set the entry for term with the new positions for docId
    this[term] = entry;
    // return true if a positions list for [docId] did not existed
    return docFieldPostings == null;
  }
}
