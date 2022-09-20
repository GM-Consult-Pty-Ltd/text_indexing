<!-- 
BSD 3-Clause License
Copyright (c) 2022, GM Consult Pty Ltd#class-persistedindexerAll rights reserved. 
-->

# text_indexing

Dart library for creating an inverted index on a collection of text documents.

*THIS PACKAGE IS **PRE-RELEASE**, IN ACTIVE DEVELOPMENT AND SUBJECT TO DAILY BREAKING CHANGES.*

Skip to section:
- [Overview](#overview)
- [Usage](#usage)
- [API](#api)
- [Definitions](#definitions)
- [References](#references)
- [Issues](#issues)

## Overview

This library provides an interface and implementation classes that build and maintain an (inverted, positional, zoned) [index](#invertedpositionalzoneindex-interface) for a collection of documents or `corpus` (see [definitions](#definitions)).

![Index construction flowchart](https://github.com/GM-Consult-Pty-Ltd/text_indexing/raw/main/assets/images/indexing.png?raw=true?raw=true "Index construction overview")

The [TextIndexer](#textindexer-interface) constructs two artifacts:
* a `dictionary` that holds the `vocabulary` of `terms` and the frequency of occurrence for each `term` in the `corpus`; and
* a `postings` map that holds a list of references to the `documents` for each `term` (the `postings list`). 

In this implementation, our `postings list` is a hashmap of the document id (`docId`) to maps that point to positions of the term in the document's zones. This allows query algorithms to score and rank search results based on the position(s) of a term in document fields, applying different weights to the zones.

![Index artifacts](https://github.com/GM-Consult-Pty-Ltd/text_indexing/raw/main/assets/images/index_artifacts.png?raw=true?raw=true "Components of inverted positional index")

Refer to the [references](#references) to learn more about information retrieval systems and the theory behind this library.

## Usage

In the `pubspec.yaml` of your flutter project, add the `text_indexing` dependency.

```yaml
dependencies:
  text_indexing: <latest version>
```

In your code file add the `text_indexing` import.

```dart
import 'package:text_indexing/text_indexing.dart';
```

For small collections, instantiate a `TextIndexer.inMemory`, (optionally passing empty `Dictionary` and `Postings` hashmaps), then iterate over a collection of documents to add them to the index.

```dart
  // - initialize a in-memory [TextIndexer] with defaults for all parameters
  final indexer =TextIndexer.inMemory();

  // - iterate through the sample data
  await Future.forEach(documents.entries, (MapEntry<String, String> doc) async {
    // - index each document
    await indexer.index(doc.key, doc.value);
  });
```

The [examples](https://pub.dev/packages/text_indexing/example) demonstrate the use of the `TextIndexer.inMemory` and  `TextIndexer.async` factories.

## API

The [API](https://pub.dev/documentation/text_indexing/latest/) exposes the [TextIndexer](#textindexer-interface) interface that builds and maintain an index for a collection of documents.

Three implementations of the [TextIndexer](#textindexer-interface) interface are provided:
* the [TextIndexerBase](#textindexerbase-class) abstract base class implements the `TextIndexer.index`, `TextIndexer.indexJson` and `TextIndexer.emit` methods;
* the [InMemoryIndexer](#inmemoryindexer-class) class is for fast indexing of a smaller corpus using in-memory dictionary and postings hashmaps; and
* the [AsyncIndexer](#persistedindexer-class) class, aimed at working with a larger corpus and asynchronous dictionaries and postings.

To maximise performance of the indexers the API manipulates nested hashmaps of DART core types `int` and `String` rather than defining strongly typed object models. To improve code legibility and maintainability the API makes use of [type aliases](#type-aliases) throughout.

### Type Aliases

* `Dictionary` is an alias for `Map<Term, Ft>`,  a hashmap of `Term` to `Ft`.
* `DictionaryEntry` is an alias for `MapEntry<Term, Ft>`, an entry in a `Dictionary`.
* `DocId` is an alias for `String`, used whenever a document id is referenced.
* `DocumentPostings` is an alias for `Map<DocId, ZonePostings>`, a hashmap of document ids to `ZonePostings`.
* `DocumentPostingsEntry` is an alias for `MapEntry<DocId, ZonePostings>`, an entry in a `DocumentPostings` hashmap.
* `ZonePostings` is an alias for `Map<Zone, TermPositions>`, a hashmap of `Zone`s to `TermPositions` in the `Zone`.
* `FieldPostingsEntry` is an alias for `MapEntry<Zone, TermPositions>`, an entry in a `ZonePostings` hashmap.
* `Ft` is an lias for `int` and denotes the frequency of a `Term` in an index or indexed object (the term frequency).
* `FtdPostings` is an alias for for `Map<String, Map<String, int>>`, a hashmap of vocabulary to hashmaps of document id to term frequency in the document.
* `IdFt` is an alias for `double`, where it represents the inverse document frequency of a term, defined as idft = log (N / dft), where N is the total number of terms in the index and dft is the document frequency of the term (number of documents that contain the term). 
* `IdFtIndex` is an alias for `Map<String, double>`, a hashmap of the vocabulary to the inverse document frequency (`Idft`)  of the term.
* `JSON` is an alias for `Map<String, dynamic>`, a hashmap known as `"Java Script Object Notation" (JSON)`, a common format for persisting data.
* `JsonCollection` is an alias for `Map<String, Map<String, dynamic>>`, a hashmap of `DocId` to `JSON` documents.
* `Pt` is an alias for `int`, used to denote the position of a `Term` in `SourceText` indexed object (the term position). 
* `TermPositions` is an alias for `List<Pt>`, an ordered `Set` of unique zero-based `Term` positions in `SourceText`, sorted in ascending order.
* `ZoneWeightMap` is a map of the zone names to their relative weighting in search results, used by scoring and ranking algorithms in information retrieval systems.

### InvertedIndex Interface

The `InvertedIndex` is an interface for an inverted, positional zoned index on a collection of documents. 

The `InvertedIndex` exposes the `analyzer` field, a text analyser that extracts tokens from text. 

The `InvertedIndex` exposes the following methods:
* `getDictionary` Asynchronously retrieves a `Dictionary` for a collection of `Term`s from a `Dictionary` repository;
* `upsertDictionary ` inserts entries into a `Dictionary` repository, overwriting any existing entries;
* `getPostings` asynchronously retrieves `Postings` for a collection of `Term`s from a `Postings` repository; 
* `upsertPostings` inserts entries into a `Postings` repository,  overwriting any existing entries;
- `getTfIndex` returns hashmap of `Term` to `Ft` for a collection of `Term`s, where `Ft` is the number of times each of the terms occurs in the `corpus`;
- `getFtdPostings` return a `FtdPostings` for a collection of `Term`s from the `Postings`, optionally filtered by minimum term frequency; and
- `getIdFtIndex` returns a `IdFtIndex` for a collection of `Term`s from the `Dictionary`.

The `InvertedIndexMixin` implements the `InvertedIndex.getTfIndex`, `InvertedIndex.getFtdPostings` and `InvertedIndex.getIdFtIndex` methods.

### TextIndexer Interface

The text indexing classes (indexers) in this library implement `TextIndexer`, an interface intended for information retrieval software applications. The design of the `TextIndexer` interface is consistent with [information retrieval theory](https://nlp.stanford.edu/IR-book/pdf/irbookonlinereading.pdf) and is intended to construct and/or maintain two artifacts:
* a hashmap with the vocabulary as key and the document frequency as the values (the `dictionary`); and
* another hashmap with the vocabulary as key and the postings lists for the linked `documents` as values (the `postings`).

The dictionary and postings can be asynchronous data sources or in-memory hashmaps.  The `TextIndexer` reads and writes to/from these artifacts using the `TextIndexer.index`.

Text or documents can be indexed by calling the following methods:
* `TextIndexer.indexText` indexes text from a text document; 
* `TextIndexer.indexJson` indexes the fields in a `JSON` document; and
* `TextIndexer.indexCollection` indexes the fields of all the documents in s JSON document collection.

Alternatively, pass a stream of documents `TextIndexer.documentStream` or `TextIndexer.collectionStream` for indexing whenever either of these streams emit (a) document(s).

The `TextIndexer.indexCollection` method indexes text from a collection of `JSON `documents, emitting the `Postings` for each document in the `TextIndexer.postingsStream`.

The `TextIndexer.emit` method adds an event to the `postingsStream`.

Listen to `TextIndexer.postingsStream` to handle the postings list emitted whenever a document is indexed.

Implementing classes override the following asynchronous methods for interacting with the `TextIndexer.index`:
- `TextIndexer.indexText` indexes a text document;
- `TextIndexer.indexJson` indexes the fields in a JSON document;
- `TextIndexer.indexCollection` indexes the fields of all the documents in a JSON document collection; and
- `TextIndexer.emit` adds an event to the `TextIndexer.postingsStream` after updating the `TextIndexer.index`;

Use one of three factory constructors to instantiate a `TextIndexer`:
* [`TextIndexer.index`](#textindexerindex); 
* [`TextIndexer.inMemory`](#textindexerinmemory); or
* [`TextIndexer.async`](#textindexerasync).

Alternatively, roll your own custom `TextIndexer` by extending [`TextIndexerBase`](#textindexerbase-class).

#### TextIndexer.index

The `TextIndexer.index` factory constructor returns a `TextIndexer` instance, using a `InvertedIndex` instance passed in as a parameter at instantiation.

#### TextIndexer.inMemory

The `TextIndexer.inMemory` factory constructor returns a `TextIndexer` instance with [in-memory](#inmemoryindex-class) `Dictionary` and `Postings` maps:
- pass a `analyzer` text analyser that extracts tokens from text;
- pass an in-memory `dictionary` instance, otherwise an empty `Dictionary` will be initialized; and
- pass an in-memory `postings` instance, otherwise an empty `Postings` will be initialized.

The `InMemoryIndexer` is suitable for indexing a smaller corpus. The `InMemoryIndexer` may have latency and processing overhead for large indexes or queries with more than a few terms. Consider running `InMemoryIndexer` in an isolate to avoid slowing down the main thread.

An example of the use of the `TextIndexer.inMemory` factory is included in the [examples](https://pub.dev/packages/text_indexing/example).

#### TextIndexer.async

The `TextIndexer.async` factory constructor returns a `TextIndexer` instance that uses
[asynchronous callback](#asynccallbackindex-class) functions to access `Dictionary` and `Postings`
repositories:
- pass a `analyzer` text analyser that extracts tokens from text;
- `dictionaryLoader` synchronously retrieves a `Dictionary` for a vocabulary from a data source;
- `dictionaryLengthLoader` asynchronously retrieves the number of terms in the vocabulary (N);
- `dictionaryUpdater` is callback that passes a `Dictionary` subset for persisting to a datastore;
- `postingsLoader` asynchronously retrieves a `Postings` for a vocabulary from a data source; and
- `postingsUpdater` passes a `Postings` subset for persisting to a datastore. 

The `AsyncIndexer` is suitable for indexing a large corpus but may have latency and processing overhead. Consider running `AsyncIndexer` in an isolate to avoid slowing down the main thread.

An example of the use of the `TextIndexer.async` factory is included in the [examples](https://pub.dev/packages/text_indexing/example).

### TextIndexerBase Class

The `TextIndexerBase` is an abstract base class that implements the `TextIndexer.indexText`, `TextIndexer.indexJson`, `TextIndexer.indexCollection` and `TextIndexer.emit` methods and the `TextIndexer.postingsStream` field. `TextIndexerBase` also initializes listeners to `TextIndexer.documentStream` and `TextIndexer.collectionStream` at instantiation.

The `TextIndexerBase.index` is updated whenever `TextIndexerBase.emit` is called. 

Subclasses of `TextIndexerBase` must implement:
* `TextIndexer.index`; and
- `TextIndexerBase.controller`, a `BehaviorSubject<Postings>` that controls the `TextIndex.postingsStream`.

### InMemoryIndex Class

The `InMemoryIndex` is a `InvertedIndex` interface implementation with in-memory `Dictionary` and `Postings` hashmaps:
- `InMemoryIndex.analyzer` is the `ITextAnalyzer` used to tokenize text for the `InMemoryIndex`;
- `InMemoryIndex.dictionary` is the in-memory term dictionary for the indexer. Pass a `dictionary` instance at instantiation, otherwise an empty `Dictionary` will be initialized; and
- `InMemoryIndex.postings` is the in-memory postings hashmap for the indexer. Pass a `postings` instance at instantiation, otherwise an empty `Postings` will be initialized.

## AsyncCallbackIndex Class

The `AsyncCallbackIndex` is a `InvertedIndex` implementation class 
that uses asynchronous callbacks to perform read and write operations on `Dictionary` and `Postings` repositories:
- `AsyncCallbackIndex.analyzer` is the `ITextAnalyzer` used to tokenize text for the `AsyncCallbackIndex`;
- `AsyncCallbackIndex.dictionaryLoader` synchronously retrieves a `Dictionary` for a vocabulary from a data source;
- `AsyncCallbackIndex.dictionaryUpdater` is callback that passes a `Dictionary` subset for persisting to `Dictionary` repository;
- `AsyncCallbackIndex.postingsLoader` asynchronously retrieves a `Postings` for a vocabulary from a data source; and
- `AsyncCallbackIndex.postingsUpdater` passes a `Postings` subset for persisting to a `Postings` repository.

## Definitions

The following definitions are used throughout the [documentation](https://pub.dev/documentation/text_indexing/latest/):

* `corpus`- the collection of `documents` for which an `index` is maintained.
* `dictionary` - is a hash of `terms` (`vocabulary`) to the frequency of occurence in the `corpus` documents.
* `document` - a record in the `corpus`, that has a unique identifier (`docId`) in the `corpus`'s primary key and that contains one or more text fields that are indexed.
* `index` - an [inverted index](https://en.wikipedia.org/wiki/Inverted_index) used to look up `document` references from the `corpus` against a `vocabulary` of `terms`. The implementation in this package builds and maintains a positional inverted index, that also includes the positions of the indexed `term` in each `document`'s zones.
* `document frequency (dFt)` is number of documents in the `corpus` that contain a term.
* `index-elimination` - selecting a subset of the entries in an index where the `term` is in the collection of `terms` in a search phrase.
* `inverse document frequency` or `iDft` is equal to log (N / `dft`), where N is the total number of terms in the index. The `IdFt` of a rare term is high, whereas the [IdFt] of a frequent term is likely to be low. 
* `JSON` is an acronym for `"Java Script Object Notation"`, a common format for persisting data.
* `lemmatizer` - lemmatisation (or lemmatization) in linguistics is the process of grouping together the inflected forms of a word so they can be analysed as a single item, identified by the word's lemma, or dictionary form (from [Wikipedia](https://en.wikipedia.org/wiki/Lemmatisation)).
* `postings` - a separate index that records which `documents` the `vocabulary` occurs in. In this implementation we also record the positions of each `term` in the `text` to create a positional inverted `index`.
* `postings list` - a record of the positions of a `term` in a `document`. A position of a `term` refers to the index of the `term` in an array that contains all the `terms` in the `text`.
* `term` - a word or phrase that is indexed from the `corpus`. The `term` may differ from the actual word used in the corpus depending on the `tokenizer` used.
* `term filter` - filters unwanted terms from a collection of terms (e.g. stopwords), breaks compound terms into separate terms and / or manipulates terms by invoking a `stemmer` and / or `lemmatizer`.
* `stemmer` -  stemming is the process of reducing inflected (or sometimes derived) words to their word stem, base or root form—generally a written word form (from [Wikipedia](https://en.wikipedia.org/wiki/Stemming)).
* `stopwords` - common words in a language that are excluded from indexing.
* `term frequency (Ft)` is the frequency of a `term` in an index or indexed object.
* `term position` is the zero-based index of a `term` in an ordered array of `terms` tokenized from the `corpus`.
* `text` - the indexable content of a `document`.
* `token` - representation of a `term` in a text source returned by a `tokenizer`. The token may include information about the `term` such as its position(s) (`term position`) in the text or frequency of occurrence (`term frequency`).
* `tokenizer` - a function that returns a collection of `token`s from `text`, after applying a character filter, `term` filter, [stemmer](https://en.wikipedia.org/wiki/Stemming) and / or [lemmatizer](https://en.wikipedia.org/wiki/Lemmatisation).
* `vocabulary` - the collection of `terms` indexed from the `corpus`.

## References

* [Manning, Raghavan and Schütze, "*Introduction to Information Retrieval*", Cambridge University Press, 2008](https://nlp.stanford.edu/IR-book/pdf/irbookprint.pdf)
* [University of Cambridge, 2016 "*Information Retrieval*", course notes, Dr Ronan Cummins, 2016](https://www.cl.cam.ac.uk/teaching/1516/InfoRtrv/)
* [Wikipedia (1), "*Inverted Index*", from Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Inverted_index)
* [Wikipedia (2), "*Lemmatisation*", from Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Lemmatisation)
* [Wikipedia (3), "*Stemming*", from Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Stemming)

## Issues

If you find a bug please fill an [issue](https://github.com/GM-Consult-Pty-Ltd/text_indexing/issues).  

This project is a supporting package for a revenue project that has priority call on resources, so please be patient if we don't respond immediately to issues or pull requests.




