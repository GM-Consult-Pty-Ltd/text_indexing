// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/text_indexing.dart';

/// Extension methods and properties on [Postings].
extension PostingsMapExtension on Postings {
  //

  /// Returns the list of [PostingsList] for the [term] from the
  /// [Postings].
  List<PostingsList> getPostings(String term) {
    final entry = this[term];
    return entry?.entries
            .map((e) => PostingsList.fromEntry(term, e))
            .toList() ??
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
  bool addTermPositions(String term, String docId, List<int> positions) {
    //
    // get the entry for the term or initialize a new one if it does not exist
    final entry = this[term] ?? <String, List<int>>{};
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
  bool addTermPosition(String term, String docId, int position) {
    //
    // get the entry for the term or initialize a new one if it does not exist
    final entry = this[term] ?? <String, List<int>>{};
    // get the existing positions list for [docId] if it exists
    final existingPositions = entry[docId];
    // initializes positions set from existingPositions or an empty list
    final set = Set<int>.from(existingPositions ?? []);
    // add position to the set
    set.add(position);
    // convert to list
    final positions = set.toList();
    // order the list of positions in ascending order
    positions.sort(((a, b) => a.compareTo(b)));
    // set the positions for docId
    entry[docId] = positions;
    // set the entry for term with the new positions for docId
    this[term] = entry;
    // return true if a positions list for [docId] did not existed
    return existingPositions == null;
  }
}
