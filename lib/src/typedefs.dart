// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

import 'package:text_indexing/src/_index.dart';

/// Alias for Map<String, dynamic>, a hashmap known as "Java Script Object
/// Notation" (Map<String, dynamic>), a common format for persisting data.
typedef JSON = Map<String, dynamic>;

/// Alias for Map<String, Map<String, dynamic>>, a hashmap of [String] to [Map<String, dynamic>]
/// documents.
typedef JsonCollection = Map<String, Map<String, dynamic>>;

/// An alias for [int], used to denote the frequency of a [Term] in an index or
/// indexed object.
typedef Ft = int;

/// Alias for `Map<Zone, double>`.
///
/// Maps the zone names to their relative weight.
typedef ZoneWeightMap = Map<Zone, double>;

/// Alias for [double] where it represents the inverse document frequency of a
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

/// Defines a term dictionary used in an inverted index.
///
/// The [Dictionary] is a hashmap of [DictionaryEntry]s with the vocabulary as
/// key and the document frequency as the values.
///
/// A [Dictionary] can be an asynchronous data source or an in-memory hashmap.
///
/// Alias for Map<String, int>.
typedef Dictionary = Map<Term, Ft>;

/// A [DictionaryEntry] is an entry in a [Dictionary].
///
/// Alias for MapEntry<Term, Ft>.
typedef DictionaryEntry = MapEntry<Term, Ft>;

/// Asynchronously retrieves a [Dictionary] subset for a collection of
/// [terms] from a [Dictionary] data source, usually persisted storage.
///
/// Loads the entire [Dictionary] if [terms] is null.
typedef DictionaryLoader = Future<Dictionary> Function([Iterable<Term>? terms]);

/// Asynchronously retrieves the number of terms in the vocabulary (N).
typedef DictionaryLengthLoader = Future<int> Function();

/// A callback that passes [values] for persisting to a [Dictionary].
///
/// Parameter [values] is a subset of a [Dictionary] containing new or changed
/// [DictionaryEntry] instances.
typedef DictionaryUpdater = Future<void> Function(Dictionary values);

/// Alias for Map<String, double>.
///
/// Maps the vocabulary [Term] to [IdFt].
typedef IdFtIndex = Map<Term, IdFt>;

/// A hashmap of [KGram] to Set<[Term]>, where the value is the set of unique
/// [Term]s that contain the [KGram] in the key.
///
/// Alias for Map<String, Set<String>>.
typedef KGramIndex = Map<KGram, Set<Term>>;

/// Asynchronously retrieves a [KGramIndex] subset for a collection of
/// [terms] from a [KGramIndex] data source, usually persisted storage.
///
/// Loads the entire [KGramIndex] if [terms] is null.
typedef KGramIndexLoader = Future<KGramIndex> Function([Iterable<Term>? terms]);

/// A callback that passes [values] for persisting to a [KGramIndex].
///
/// Parameter [values] is a subset of a [KGramIndex] containing new or changed
/// entries.
typedef KGramIndexUpdater = Future<void> Function(KGramIndex values);

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

/// Type definition for a hashmap of [DocId] to [ZonePostings].
typedef DocumentPostings = Map<DocId, ZonePostings>;

/// Type definition for a hashmap entry of [DocId] to [ZonePostings] in a
/// [DocumentPostings] hashmap.
typedef DocumentPostingsEntry = MapEntry<DocId, ZonePostings>;

/// Type definition for a hashmap of [Zone]s to [TermPositions].
typedef ZonePostings = Map<Zone, TermPositions>;

/// Type definition for a hashmap entry of [Zone] to [TermPositions] in a
/// [ZonePostings] hashmap.
typedef FieldPostingsEntry = MapEntry<Zone, TermPositions>;

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
