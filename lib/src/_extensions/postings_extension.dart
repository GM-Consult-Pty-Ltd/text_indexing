// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/text_indexing.dart';

/// Extension methods and properties on [Postings].
extension PostingsMapExtension on Postings {
  //

  /// Filters the [Postings] by [terms], [docIds] AND [fields].
  ///
  /// Filter is applied by succesively calling, in order:
  /// - [termPostings] if [terms] is not null; then
  /// - [documentPostings], if [docIds] is not null; and finally
  /// - [fieldPostings], if [fields] is not null.
  Postings filter(
      {Iterable<String>? terms,
      Iterable<String>? docIds,
      Iterable<String>? fields}) {
    Postings retVal = terms != null ? termPostings(terms) : Postings.from(this);
    retVal = docIds != null ? retVal.documentPostings(docIds) : retVal;
    return fields != null ? retVal.fieldPostings(fields) : retVal;
  }

  /// Filters the [Postings] by terms.
  ///
  /// Returns a subset of the [Postings] instance that only contains
  /// entires with a key in the [terms] collection.
  Postings termPostings(Iterable<String> terms) {
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
  Postings documentPostings(Iterable<String> docIds) => Postings.from(this)
    ..removeWhere((key, value) =>
        value.keys.toSet().intersection(docIds.toSet()).isEmpty);

  /// Filters the [Postings] by field names.
  ///
  /// Returns a subset of the [Postings] instance that only contains entries
  /// where a field name in [fields] has a key in any document's postings the
  /// entry's postings lists.
  Postings fieldPostings(Iterable<String> fields) => Postings.from(this)
    ..removeWhere((key, value) {
      final docFields = <String>[];
      for (final doc in value.values) {
        docFields.addAll(doc.keys);
      }
      return docFields.toSet().intersection(fields.toSet()).isEmpty;
    });

  /// Returns the list of [PostingsMap] for the [term] from the
  /// [Postings].
  List<PostingsMap> termPostingsList(String term) {
    final entry = this[term];
    return entry?.entries.map((e) => PostingsMap.fromEntry(term, e)).toList() ??
        [];
  }

  /// Returns the list of [PostingsEntry] elements in the [Postings] in
  /// alphapetic order of the terms (keys).
  List<PostingsEntry> toList() {
    final postingsMapEntries =
        entries.map((e) => PostingsEntry.fromEntry(e)).toList();
    postingsMapEntries.sort((a, b) => a.term.compareTo(b.term));
    return postingsMapEntries;
  }

  /// Returns the dictionary terms (keys) as an ordered list,
  /// sorted alphabetically.
  List<String> get terms {
    final terms = keys.toList();
    terms.sort((a, b) => a.compareTo(b));
    return terms;
  }

  /// Inserts or replaces the [value] in the [Postings].
  void addEntry(PostingsEntry value) =>
      this[value.term] = value.toMapEntry().value;

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
  bool addTermPositions(
      String term, String docId, Map<String, List<int>> positions) {
    //
    // get the entry for the term or initialize a new one if it does not exist
    final entry = this[term] ?? <String, Map<String, List<int>>>{};
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
      {required String term,
      required String docId,
      required int position,
      String? field}) {
    //
    field = field ?? 'null';
    // get the entry for the term or initialize a new one if it does not exist
    final entry = this[term] ?? {};
    // get the existing field postings for [docId] if it exists
    final docPostings = entry[docId] ?? {};
    // get the existing psitions in the field for [field] if it exists
    final docFieldPostings = docPostings[field];
    // initializes positions set from docFieldPostings or an empty list
    final set = Set<int>.from(docFieldPostings ?? []);
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
