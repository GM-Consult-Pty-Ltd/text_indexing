// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/src/_index.dart';

/// A MapEntry<String, Map<String, double>>` enumerates the properties of an
/// entry in a [KeywordPostingsMap] collection:
/// - [keyword] is the keyword that is indexed; and
/// - [postings] is a hashmap of the [MapEntry<String, double>] for [keyword].
extension KeywordPostingsEntryExtension
    on MapEntry<String, Map<String, double>> {
  //



  /// Returns [key], the indexed [String].
  String get keyword => key;

  /// Returns [value], a hashmap of the [DocId] to keyword score.
  Map<String, double> get postings => value;
}

/// The [MapEntry<String, double>] class enumerates the properties of a document
/// posting in a [KeywordPostingsMap] as part of an inverted index of a dataset:
/// - [docId] is the document's id value, (the [MapEntry<String, double>.key]);
/// - [score] is a hashmap of zone names that contain the keyword to
///   the a zero-based, ordered list of word positions of the keyword in the
///   zone (the [MapEntry<String, double>.value]).
extension KeywordDocumentPostingsEntryExtension on MapEntry<String, double> {
  //
  /// The document's id value.
  ///
  /// Usually the value of the document's primary key zone in the dataset.
  DocId get docId => key;

  /// A hashmap of zone names that contain the keyword to the a zero-based,
  /// ordered list of unique word positions of the [String] in the zone.
  ///
  /// A word position means the index of the word in an array of all the words
  /// in the document.
  double get score => value;
}

/// Extension methods and properties on [KeywordPostingsMap].
extension KeywordPostingsExtension on KeywordPostingsMap {
  //

  /// Returns a [Set] of [DocId] of those documents that contain all the
  /// [keywords].
  Set<DocId> containsAll(Iterable<String> keywords) {
    final byTerm = getKeywordsPostings(keywords);
    Set<String> intersection = byTerm.docIds;
    for (final docPostings in byTerm.values) {
      intersection = intersection.intersection(docPostings.keys.toSet());
    }
    return intersection;
  }

  /// Returns a [Set] of [DocId] of those documents that contain any of
  /// the [keywords]. Used for `index-elimination` as a fist pass in scoring and
  /// ranking of search results.
  Set<DocId> containsAny(Iterable<String> keywords) =>
      getKeywordsPostings(keywords).docIds;

  /// Returns all the unique document ids ([DocId]) in the [KeywordPostingsMap].
  Set<DocId> get docIds {
    final Set<DocId> retVal = {};
    for (final docPostings in values) {
      retVal.addAll(docPostings.keys);
    }
    return retVal;
  }

  /// Filters the [KeywordPostingsMap] by [keywords] AND [docIds].
  ///
  /// Filter is applied by succesively calling, in order:
  /// - [getKeywordsPostings] if [keywords] is not null; then
  /// - [documentPostings], if [docIds] is not null
  KeywordPostingsMap filter(
      {Iterable<String>? keywords, Iterable<DocId>? docIds}) {
    KeywordPostingsMap retVal = keywords != null
        ? getKeywordsPostings(keywords)
        : KeywordPostingsMap.from(this);
    retVal = docIds != null ? retVal.documentPostings(docIds) : retVal;
    return retVal;
  }

  /// Filters the [KeywordPostingsMap] by keywords.
  ///
  /// Returns a subset of the [KeywordPostingsMap] instance that only contains
  /// entires with a key in the [keywords] collection.
  KeywordPostingsMap getKeywordsPostings(Iterable<String> keywords) {
    final newEntries =
        entries.where((element) => keywords.contains(element.key));
    final KeywordPostingsMap retVal = {}..addEntries(newEntries);
    return retVal;
  }

  /// Returns the list of all the entries for the [keyword]
  /// from the [KeywordPostingsMap].
  List<MapEntry<String, double>> keywordPostings(String keyword) =>
      this[keyword]?.entries.toList() ?? [];

  /// Filters the [KeywordPostingsMap] by document ids.
  ///
  /// Returns a subset of the [KeywordPostingsMap] instance that only contains entries
  /// where a document id in [docIds] has a key in the entry's postings lists.
  KeywordPostingsMap documentPostings(Iterable<DocId> docIds) =>
      KeywordPostingsMap.from(this)
        ..removeWhere((key, value) =>
            value.keys.toSet().intersection(docIds.toSet()).isEmpty);

  /// Returns the list of all the [MapEntry<String, double>] for the [keywords]
  /// from the [KeywordPostingsMap].
  ///
  /// Returns all the [MapEntry<String, double>] instances for all keywords in
  /// the [KeywordPostingsMap] if [keywords] is null.
  List<MapEntry<String, double>> keywordPostingsList(
      [Iterable<String>? keywords]) {
    final List<MapEntry<String, double>> keywordPostings = [];
    if (keywords != null) {
      for (final keyword in keywords) {
        final entry = this[keyword];
        if (entry != null) {
          keywordPostings.addAll(entry.entries);
        }
      }
    } else {
      for (final entry in values) {
        keywordPostings.addAll(entry.entries);
      }
    }
    return keywordPostings;
  }

  // /// Returns the list of [PostingsMapEntry] elements in the [KeywordPostingsMap] in
  // /// alphapetic order of the keywords (keys).
  // List<PostingsMapEntry> toList() => entries.toList();

  /// Returns the keywords (keys) as an ordered list,
  /// sorted alphabetically.
  List<String> get keywords {
    final keywords = keys.toList();
    keywords.sort((a, b) => a.compareTo(b));
    return keywords;
  }

  /// Adds a keword score for the [docId] to [KeywordPostingsMap] entry for the
  /// [keyword].
  ///
  /// Returns true if a keyword score for the [docId] did not previously
  /// exist in the [KeywordPostingsMap].
  ///
  /// Looks up an existing entry for [keyword] and inserts/overwrites an entry
  /// for [docId] if it exists.
  ///
  /// If no entry for [keyword] exists in the [KeywordPostingsMap], creates a
  /// new entry and adds [score] for [docId] to the new entry.
  bool addDocKeywordScore(String keyword, DocId docId, double score) {
    //
    // get the entry for the keyword or initialize a new one if it does not exist
    final Map<String, double> entry = this[keyword] ?? {};
    // get the existing positions list for [docId] if it exists
    final existingEntry = entry[docId];
    // overwrite the positions for docId
    entry[docId] = score;
    // set the entry for keyword with the new positions for docId
    this[keyword] = entry;
    // return true if a positions list for [docId] did not existed
    return existingEntry == null;
  }
}
