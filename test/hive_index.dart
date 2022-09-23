// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

// ignore_for_file: deprecated_member_use_from_same_package

import 'package:text_indexing/text_indexing.dart';
import 'package:hive/hive.dart';
import 'dart:convert';

/// The HiveIndex is an implementation of the [InvertedIndex] interface
/// that mixes in [InvertedIndexMixin] and [HiveIndexMixin].
///
/// The [HiveIndex] persists the index to the local file system as a collection
/// of Hive [Box] instances.
class HiveIndex
    with HiveIndexMixin, InvertedIndexMixin
    implements InvertedIndex {
  //

  @override
  final int k;

  /// Instantiates a [HiveIndex] instance:
  /// - [analyzer] is the [ITextAnalyzer] used to tokenize text for the index;
  /// - [k] is the length of k-gram entries in the k-gram index;
  /// - [zones] is a hashmap of zone names to their relative weight in the
  ///   index;
  /// - [phraseLength] is the maximum length of phrases in the index vocabulary
  ///   and must be greater than 0.
  /// - [dictionaryBox] is the [Box] for the [Dictionary];
  /// - [kGramIndexBox] is the [Box] for the [KGramIndex]; and
  /// - [postingsBox] is the [Box] for the [Postings]. P
  HiveIndex(
      {required this.dictionaryBox,
      required this.postingsBox,
      required this.kGramIndexBox,
      this.analyzer = const TextAnalyzer(),
      this.k = 3,
      this.zones = const <String, double>{},
      this.phraseLength = 1})
      : assert(phraseLength > 0, 'The phrase length must be 1 or greater');

  @override
  final Box<int> dictionaryBox;

  @override
  final Box<String> postingsBox;

  @override
  final Box<String> kGramIndexBox;

  @override
  final ITextAnalyzer analyzer;

  @override
  final ZoneWeightMap zones;

  @override
  final int phraseLength;
}

/// A mixin class that implements [InvertedIndex]. The mixin exposes
/// [dictionaryBox], [kGramIndexBox] and [postingsBox] fields of type
/// [Box]<String> that must be overriden.
///
/// Provides implementation of the following methods for operations on the Hive
/// [postingsBox], [kGramIndexBox] and [dictionaryBox] repository [Box] instances:
/// - [vocabularyLength] returns the number of entries in the Hive
///   [dictionaryBox].
/// - [getDictionary] retrieves a [Dictionary] for a collection of [Term]s from
///   the Hive [dictionaryBox];
/// - [upsertDictionary ] inserts entries into the Hive [dictionaryBox],
///   overwriting any existing entries;
/// - [getPostings] retrieves [Postings] for a collection of [Term]s from the
///   Hive [postingsBox];
/// - [upsertPostings] inserts entries into the Hive [postingsBox],
///   overwriting any existing entries;
/// - [getKGramIndex] retrieves entries for a collection of [Term]s from the
///   Hive [kGramIndexBox]; and
/// - [upsertKGramIndex] inserts entries into the Hive [kGramIndexBox],
///   overwriting any existing entries.
abstract class HiveIndexMixin implements InvertedIndex {
  //

  /// The Hive term dictionaryBox for the index.
  Box<int> get dictionaryBox;

  /// The Hive postingsBox hashmap for the index.
  Box<String> get postingsBox;

  /// The Hive [KGramIndex] for the index.
  Box<String> get kGramIndexBox;

  @override
  Future<Ft> get vocabularyLength async => dictionaryBox.length;

  @override
  Future<Postings> getPostings(Iterable<Term> terms) async {
    final Postings retVal = {};
    for (final term in terms) {
      final entry = postingsBox.get(term);
      if (entry != null) {
        retVal[term] = (jsonDecode(entry) as Map).map((k, e) => MapEntry(
            k as String,
            (e as Map).map((k, e) => MapEntry(
                k as String, (e as List).map((e) => e as int).toList()))));
        //   Map<String, Map<String, List<int>>>.from(jsonDecode(entry) as Map);
      }
    }
    return retVal;
  }

  @override
  Future<Dictionary> getDictionary([Iterable<Term>? terms]) async {
    terms = terms ?? List<String>.from(dictionaryBox.keys);
    final Dictionary retVal = {};
    for (final term in terms) {
      final entry = dictionaryBox.get(term);
      if (entry != null) {
        retVal[term] = entry;
      }
    }
    return retVal;
  }

  @override
  Future<void> upsertDictionary(Dictionary values) async =>
      dictionaryBox.putAll(values);

  @override
  Future<void> upsertPostings(Postings values) async => postingsBox
      .putAll(values.map((key, value) => MapEntry(key, jsonEncode(value))));

  @override
  Future<KGramIndex> getKGramIndex([Iterable<KGram>? kGrams]) async {
    kGrams = kGrams ?? List<String>.from(kGramIndexBox.keys);
    final KGramIndex retVal = {};
    for (final kGram in kGrams) {
      final entry = kGramIndexBox.get(kGram);
      if (entry != null) {
        retVal[kGram] =
            (List<String>.from(jsonDecode(entry) as Iterable)).toSet();
      }
    }
    return retVal;
  }

  @override
  Future<void> upsertKGramIndex(KGramIndex values) async =>
      kGramIndexBox.putAll(values
          .map((key, value) => MapEntry(key, jsonEncode(value.toList()))));
}
