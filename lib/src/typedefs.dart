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

/// An alias for `int`, used to denote the frequency of a [Term] in an index or
/// indexed object.
typedef Ft = int;

/// Alias for `Map<Zone, double>`.
///
/// Maps the zone names to their relative weight.
typedef ZoneWeightMap = Map<Zone, double>;

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
typedef FtdPostings = Map<Term, Map<DocId, Ft>>;

/// Alias for `Map<String, int>`.
///
/// Defines a term dictionary used in an inverted index.
///
/// The [DftMap] is a hashmap of [DftMapEntry]s with the vocabulary as
/// key and the document frequency as the values.
///
/// A [DftMap] can be an asynchronous data source or an in-memory hashmap.
typedef DftMap = Map<Term, Ft>;

/// Alias for `MapEntry<Term, Ft>`.
///
/// A [DftMapEntry] is an entry in a [DftMap].
typedef DftMapEntry = MapEntry<Term, Ft>;

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
typedef VocabularySize = Future<int> Function();

/// Alias for `Map<String, double>`.
///
/// Maps the vocabulary [Term] to [IdFt].
typedef IdFtIndex = Map<Term, IdFt>;

/// A callback that asynchronously retrieves a [KGramsMap] subset for a
/// collection of [terms] from a [KGramsMap] data source,
/// usually persisted storage.
///
/// Loads the entire [KGramsMap] if [terms] is null.
typedef KGramsMapLoader = Future<KGramsMap> Function([Iterable<Term>? terms]);

/// A callback that passes [values] for persisting to a [KGramsMap].
///
/// Parameter [values] is a subset of a [KGramsMap] containing new or changed
/// entries.
typedef KGramsMapUpdater = Future<void> Function(KGramsMap values);

/// Type definition for a hashmap of [Term] to [DocPostingsMap].
typedef PostingsMap = Map<Term, DocPostingsMap>;

/// Type definition for a hashmap entry of [Term] to [DocPostingsMap] in a
/// [PostingsMap] hashmap.
typedef PostingsMapEntry = MapEntry<Term, DocPostingsMap>;

/// An alias for [int], used to denote the position of a [Term] in [SourceText]
/// indexed object (the term position).
typedef Pt = int;

/// An alias for [String], used whenever a document id is referenced.
typedef DocId = String;

/// Type definition for a hashmap of [DocId] to [ZonePostingsMap].
typedef DocPostingsMap = Map<DocId, ZonePostingsMap>;

/// Type definition for a hashmap entry of [DocId] to [ZonePostingsMap] in a
/// [DocPostingsMap] hashmap.
typedef DocPostingsMapEntry = MapEntry<DocId, ZonePostingsMap>;

/// Type definition for a hashmap of [Zone]s to [TermPositions].
typedef ZonePostingsMap = Map<Zone, TermPositions>;

/// Type definition for a hashmap entry of [Zone] to [TermPositions] in a
/// [ZonePostingsMap] hashmap.
typedef ZonePostingsMapEntry = MapEntry<Zone, TermPositions>;

/// Type definition for an ordered [Set] of unique zero-based term
/// positions in a text source, sorted in ascending order.
typedef TermPositions = List<Pt>;

/// Asynchronously retrieves a [PostingsMap] subset for a collection of
/// [terms] from a [PostingsMap] data source, usually persisted storage.
typedef PostingsMapLoader = Future<PostingsMap> Function(Iterable<Term> terms);

/// A callback that [values] for persisting to a [PostingsMap].
///
/// Parameter [values] is a subset of a [PostingsMap] containing new or changed
/// [PostingsMapEntry] instances.
typedef PostingsMapUpdater = Future<void> Function(PostingsMap values);
