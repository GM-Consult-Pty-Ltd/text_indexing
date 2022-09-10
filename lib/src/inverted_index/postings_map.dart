// Copyright ©2022, GM Consult (Pty) Ltd.
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/text_indexing.dart';

/// Defines a collection of postings for a positional inverted index.
///
/// [PostingsMap] is a hashmap of [Term]s where:
/// - the key is the word/term that is indexed; and
/// - the value is a hashmap of document ids to a [List] of positions of the term
///   in each document.
typedef PostingsMap = Map<String, Map<String, List<int>>>;

/// Extension methods and properties on [PostingsMap].
extension PostingsMapExtension on PostingsMap {
  //

  /// Returns the list of [TermPositions] for the [term] from the
  /// [PostingsMap].
  List<TermPositions> getPostings(String term) {
    final entry = this[term];
    return entry?.entries
            .map((e) => TermPositions.fromEntry(term, e))
            .toList() ??
        [];
  }

  /// Returns the list of [PostingsMapEntry] elements in the [PostingsMap] in
  /// alphapetic order of the terms (keys).
  List<PostingsMapEntry> toList() {
    final postingsMapEntries =
        entries.map((e) => PostingsMapEntry.fromEntry(e)).toList();
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

  /// Inserts or replaces the [value] in the [PostingsMap].
  void addEntry(PostingsMapEntry value) =>
      this[value.term] = value.toMapEntry().value;

  /// Adds a postings for the [docId] to [PostingsMap] entry for the [term].
  ///
  /// Looks up an existing entry for [term] and inserts/overwrites an entry
  /// for [docId] if it exists.
  ///
  /// If no entry for [term] exists in the [PostingsMap], creates a new entry
  /// and adds [positions] for [docId] to the new entry.
  void addTermPositions(String term, String docId, List<int> positions) {
    final entry = this[term] ?? <String, List<int>>{};
    entry[docId] = positions;
    this[term] = entry;
  }
}

/// The [PostingsMapEntry] class enumerates the properties of entry in a
/// [PostingsMap] as part of an inverted index of a dataList:
/// - [term] is the word/term that is indexed; and
/// - [postings] is a hashmap of the [TermPositions] for [term].
class PostingsMapEntry {
  //

  /// Serializes the [PostingsMapEntry] to a MapEntry for direct insertion in
  /// a [PostingsMap].
  MapEntry<String, Map<String, List<int>>> toMapEntry() => MapEntry(
      term,
      postings
          .map((key, value) => MapEntry(key, List<int>.from(value.positions))));

  /// The word/term that is indexed.
  ///
  /// The [term] must not be an empty String.
  ///
  /// The [term] must only occur once in the [TermDictionary].
  final String term;

  /// A hashmap of the [TermPositions] for [term] where:
  /// - the [postings].key is the id of the document;
  /// - the [postings].value is the postings in the document of the [term].
  final Map<String, TermPositions> postings;

  /// Instantiates a const [PostingsMapEntry] instance:
  /// - [term] is the word/term that is indexed; and
  /// - [postings] is a hashmap of the [TermPositions] for [term].
  const PostingsMapEntry(this.term, this.postings);

  /// Factory constructor that instantiates a [PostingsMapEntry] instance from
  /// a [PostingsMap] map entry.
  factory PostingsMapEntry.fromEntry(
      MapEntry<String, Map<String, List<int>>> entry) {
    final term = entry.key;
    final postings = entry.value.map((key, value) =>
        MapEntry(key, TermPositions.fromEntry(term, MapEntry(key, value))));

    return PostingsMapEntry(term, postings);
  }
}
