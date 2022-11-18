// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/src/_index.dart';

/// Alias for `Map<String, dynamic>`, a hashmap known as `Java Script Object
/// Notation`, a common format for persisting data.
typedef JSON = Map<String, dynamic>;

/// Alias for `Map<String, Map<String, dynamic>>`, a hashmap of
/// `String` to `Map<String, dynamic>` documents.
typedef JsonCollection = Map<String, Map<String, dynamic>>;

/// An alias for `int`, used to denote the frequency of a term in an index or
/// indexed object.
typedef Ft = int;

/// Alias for `Map<String, double>`.
///
/// Maps the zone names to their relative weight.
typedef ZoneWeightMap = Map<String, double>;

/// Alias for `double` where it represents the inverse document frequency of a
/// term.
///
/// IdFt is defined as `idft = log (N / dft)`, where:
/// - N is the total number of terms in the index;
/// - dft is the document frequency of the term (number of documents that
///   contain the term).
/// The [IdFt] of a rare term is high, whereas the [IdFt] of a frequent term is
/// likely to be low.
typedef IdFt = double;

/// Alias for `Map<String, Map<String, int>>`.
///
/// Maps the vocabulary to hashmaps of document id to term frequency in the
/// document.
typedef FtdPostings = Map<String, Map<String, Ft>>;

/// Alias for `Map<String, int>`.
///
/// Defines a term dictionary used in an inverted index.
///
/// The [DftMap] is a hashmap of [DftMapEntry]s with the vocabulary as
/// key and the document frequency as the values.
///
/// A [DftMap] can be an asynchronous data source or an in-memory hashmap.
typedef DftMap = Map<String, Ft>;

/// Alias for `MapEntry<String, Ft>`.
///
/// A [DftMapEntry] is an entry in a [DftMap].
typedef DftMapEntry = MapEntry<String, Ft>;

/// A callback that asynchronously retrieves a [DftMap] subset for a collection
/// of [terms] from a [DftMap] data source, usually persisted storage.
///
/// Loads the entire [DftMap] if [terms] is null.
typedef DftMapLoader = Future<Map<String, int>> Function(
    [Iterable<String>? terms]);

/// A callback that passes [values] for persisting to a [DftMap].
///
/// Parameter [values] is a subset of a [DftMap] containing new or changed
/// [DftMapEntry] instances.
typedef DftMapUpdater = Future<void> Function(DftMap values);

/// A callback that asynchronously retrieves the number of terms in the
/// vocabulary (N).
typedef CollectionSizeCallback = Future<int> Function();

/// Alias for `Map<String, double>`.
///
/// Maps the vocabulary term to [IdFt].
typedef IdFtIndex = Map<String, IdFt>;

/// A callback that asynchronously retrieves a [KGramsMap] subset for a
/// collection of [terms] from a [KGramsMap] data source,
/// usually persisted storage.
///
/// Loads the entire [KGramsMap] if [terms] is null.
typedef KGramsMapLoader = Future<KGramsMap> Function([Iterable<String>? terms]);

/// A callback that passes [values] for persisting to a [KGramsMap].
///
/// Parameter [values] is a subset of a [KGramsMap] containing new or changed
/// entries.
typedef KGramsMapUpdater = Future<void> Function(KGramsMap values);

/// Type definition for a hashmap of term to [DocPostingsMap].
typedef PostingsMap = Map<String, DocPostingsMap>;

/// Type definition for a hashmap entry of term to [DocPostingsMap] in a
/// [PostingsMap] hashmap.
///
/// Alias for `MapEntry<String, Map<String, Map<String, List<int>>>>`.
typedef PostingsMapEntry = MapEntry<String, DocPostingsMap>;

/// Type definition for a hashmap of keywords to a map of document ids to
/// keyword scores for that keyword in each document.
///
/// Alias for `Map<String, Map<String, double>>`.
typedef KeywordPostingsMap = Map<String, KeyWordPostings>;

/// Type definition for a hashmap of document ids to keyword scores for a
/// keyword in each document.
///
/// Alias for `Map<String, double>`.
typedef KeyWordPostings = Map<String, double>;

/// An alias for [int], used to denote the position of a term in [String]
/// indexed object (the term position).
///
/// Alias for `int`;
typedef Pt = int;

/// Type definition for a hashmap of document id to [ZonePostingsMap].
///
/// Alias for `Map<String, List<int>>`.
typedef DocPostingsMap = Map<String, ZonePostingsMap>;

/// Type definition for a hashmap entry of document id to [ZonePostingsMap] in a
/// [DocPostingsMap] hashmap.
///
/// Alias for `MapEntry<String, Map<String, List<int>>>`.
typedef DocPostingsMapEntry = MapEntry<String, ZonePostingsMap>;

/// Type definition for a hashmap of zones to [TermPositions].
///
/// Alias for `Map<String, List<int>>`.
typedef ZonePostingsMap = Map<String, TermPositions>;

/// Type definition for a hashmap entry of zone to [TermPositions] in a
/// [ZonePostingsMap] hashmap.
///
/// Alias for `MapEntry<String, List<int>>`.
typedef ZonePostingsMapEntry = MapEntry<String, TermPositions>;

/// Type definition for an ordered [Set] of unique zero-based term
/// positions in a text source, sorted in ascending order.
typedef TermPositions = List<Pt>;

/// Asynchronously retrieves a [PostingsMap] subset for a collection of
/// [terms] from a [PostingsMap] data source, usually persisted storage.
typedef PostingsMapLoader = Future<PostingsMap> Function(
    Iterable<String> terms);

/// A callback that [values] for persisting to a [PostingsMap].
///
/// Parameter [values] is a subset of a [PostingsMap] containing new or changed
/// [PostingsMapEntry] instances.
typedef PostingsMapUpdater = Future<void> Function(PostingsMap values);

/// Asynchronously retrieves a [KeywordPostingsMap] subset for a collection of
/// [keywords] from a [KeywordPostingsMap] data source, usually persisted storage.
typedef KeywordPostingsMapLoader = Future<KeywordPostingsMap> Function(
    Iterable<String> keywords);

/// A callback that [values] for persisting to a [KeywordPostingsMap].
///
/// Parameter [values] is a subset of a [KeywordPostingsMap] containing new or changed
/// [PostingsMapEntry] instances.
typedef KeywordPostingsMapUpdater = Future<void> Function(
    KeywordPostingsMap values);
