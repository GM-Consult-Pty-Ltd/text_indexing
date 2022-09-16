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

In this implementation, our `postings list` is a hashmap of the document id (`docId`) to maps that point to positions of the term in the document's fields (zones). This allows query algorithms to score and rank search results based on the position(s) of a term in document fields, applying different weights to the zones.

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
* `DocumentPostings` is an alias for `Map<DocId, FieldPostings>`, a hashmap of document ids to `FieldPostings`.
* `DocumentPostingsEntry` is an alias for `MapEntry<DocId, FieldPostings>`, an entry in a `DocumentPostings` hashmap.
* `FieldPostings` is an alias for `Map<FieldName, TermPositions>`, a hashmap of `FieldName`s to `TermPositions` in the field with `FieldName`.
* `FieldPostingsEntry` is an alias for `MapEntry<FieldName, TermPositions>`, an entry in a `FieldPostings` hashmap.
* `Ft` is an lias for `int` and denotes the frequency of a `Term` in an index or indexed object (the term frequency).
* `JSON` is an alias for `Map<String, dynamic>`, a hashmap known as `"Java Script Object Notation" (JSON)`, a common format for persisting data.
* `JsonCollection` is an alias for `Map<String, Map<String, dynamic>>`, a hashmap of `DocId` to `JSON` documents.
* `Pt` is an alias for `int`, used to denote the position of a `Term` in `SourceText` indexed object (the term position). 
* `TermPositions` is an alias for `List<Pt>`, an ordered `Set` of unique zero-based `Term` positions in `SourceText`, sorted in ascending order.

### InvertedPositionalZoneIndex Interface

The `InvertedPositionalZoneIndex` is an interface for an inverted, positional zoned index on a collection of documents. 

The `InvertedPositionalZoneIndex` exposes the `analyzer` field, a text analyser that extracts tokens from text. 

The `InvertedPositionalZoneIndex` exposes the following methods:
* `getDictionary` Asynchronously retrieves a `Dictionary` for a collection of `Term`s from a `Dictionary` repository;
* `upsertDictionary ` inserts entries into a `Dictionary` repository, overwriting any existing entries;
* `getPostings` asynchronously retrieves `Postings` for a collection of `Term`s from a `Postings` repository; and 
* `upsertPostings` inserts entries into a `Postings` repository,  overwriting any existing entries.

### TextIndexer Interface

The text indexing classes (indexers) in this library implement `TextIndexer`, an interface intended for information retrieval software applications. The design of the `TextIndexer` interface is consistent with [information retrieval theory](https://nlp.stanford.edu/IR-book/pdf/irbookonlinereading.pdf) and is intended to construct and/or maintain two artifacts:
* a hashmap with the vocabulary as key and the document frequency as the values (the `dictionary`); and
* another hashmap with the vocabulary as key and the postings lists for the linked `documents` as values (the `postings`).

The dictionary and postings can be asynchronous data sources or in-memory hashmaps.  The `TextIndexer` reads and writes to/from these artifacts using the `TextIndexer.index`.

Text or documents can be indexed by calling the following methods:
* `TextIndexer.indexJson` indexes the fields in a `JSON` document; 
* `TextIndexer.indexText` indexes text from a text document.
* The `TextIndexer.indexCollection` method indexes text from a collection of `JSON `documents, emitting the `Postings` for each document in the `TextIndexer.postingsStream`.

The `TextIndexer.emit` method adds an event to the `postingsStream`.

Listen to `TextIndexer.postingsStream` to handle the postings list emitted whenever a document is indexed.

Implementing classes override the following fields:
- `TextIndexer.index` is the `InvertedPositionalZoneIndex` that provides access to the index `Dictionary` and `Postings` and a `ITextAnalyzer`;
- `TextIndexer.postingsStream` emits a `Postings` whenever a document is indexed.

Implementing classes override the following asynchronous methods:
- `TextIndexer.indexText` indexes a text document;
- `TextIndexer.indexJson` indexes the fields in a JSON document;
- `TextIndexer.indexCollection` indexes the fields of all the documents in JSON document collection; and
- `TextIndexer.emit` adds an event to the `TextIndexer.postingsStream` after updating the `TextIndexer.index`;

### TextIndexerBase Class

The `TextIndexerBase` is an abstract base class that implements the `TextIndexer.indexText`, `TextIndexer.indexJson`, `TextIndexer.indexCollection` and `TextIndexer.emit` methods and the `TextIndexer.postingsStream` field.

The `TextIndexerBase.index` is updated whenever `TextIndexerBase.emit` is called. 

Subclasses of `TextIndexerBase` must implement:
* `TextIndexer.index`; and
- `TextIndexerBase.controller`, a `BehaviorSubject<Postings>` that controls the `TextIndex.postingsStream`.

### InMemoryIndex Class

The `InMemoryIndex` is a `InvertedPositionalZoneIndex` interface implementation with in-memory `Dictionary` and `Postings` hashmaps:
- `InMemoryIndex.analyzer` is the `ITextAnalyzer` used to tokenize text for the `InMemoryIndex`;
- `InMemoryIndex.dictionary` is the in-memory term dictionary for the indexer. Pass a `dictionary` instance at instantiation, otherwise an empty `Dictionary` will be initialized; and
- `InMemoryIndex.postings` is the in-memory postings hashmap for the indexer. Pass a `postings` instance at instantiation, otherwise an empty `Postings` will be initialized.

### InMemoryIndexer Class

The `InMemoryIndexer` is a subclass of [TextIndexerBase](#textindexerbase-class) that builds and maintains an in-memory `Dictionary` and `Postings` and can be initialized using the `TextIndexer.inMemory` factory. 

The `InMemoryIndexer` is suitable for indexing a smaller corpus. The `InMemoryIndexer` may have latency and processing overhead for large indexes or queries with more than a few terms. Consider running `InMemoryIndexer` in an isolate to avoid slowing down the main thread.

An example of the use of the `TextIndexer.inMemory` factory is included in the [examples](https://pub.dev/packages/text_indexing/example).

## AsyncCallbackIndex Class

The `AsyncCallbackIndex` is a `InvertedPositionalZoneIndex` implementation class 
that uses asynchronous callbacks to perform read and write operations on `Dictionary` and `Postings` repositories:
- `AsyncCallbackIndex.analyzer` is the `ITextAnalyzer` used to tokenize text for the `AsyncCallbackIndex`;
- `AsyncCallbackIndex.termsLoader` synchronously retrieves a `Dictionary` for a vocabulary from a data source;
- `AsyncCallbackIndex.dictionaryUpdater` is callback that passes a `Dictionary` subset for persisting to `Dictionary` repository;
- `AsyncCallbackIndex.postingsLoader` asynchronously retrieves a `Postings` for a vocabulary from a data source; and
- `AsyncCallbackIndex.postingsUpdater` passes a `Postings` subset for persisting to a `Postings` repository.

### AsyncIndexer Class

The `AsyncIndexer` is a subclass of [TextIndexerBase](#textindexerbase-class) that asynchronously reads and writes from / to a `Dictionary` and `Postings` using asynchronous callbacks. A `AsyncIndexer` can be initialized using the `TextIndexer.async` factory. 

The `AsyncIndexer` is suitable for indexing a large corpus but may have latency and processing overhead. Consider running `AsyncIndexer` in an isolate to avoid slowing down the main thread.

An example of the use of the `TextIndexer.async` factory is included in the [examples](https://pub.dev/packages/text_indexing/example).

## Definitions

The following definitions are used throughout the [documentation](https://pub.dev/documentation/text_indexing/latest/):

* `corpus`- the collection of `documents` for which an `index` is maintained.
* `dictionary` - is a hash of `terms` (`vocabulary`) to the frequency of occurence in the `corpus` documents.
* `document` - a record in the `corpus`, that has a unique identifier (`docId`) in the `corpus`'s primary key and that contains one or more text fields that are indexed.
* `index` - an [inverted index](https://en.wikipedia.org/wiki/Inverted_index) used to look up `document` references from the `corpus` against a `vocabulary` of `terms`. The implementation in this package builds and maintains a positional inverted index, that also includes the positions of the indexed `term` in each `document`'s fields (zones).
* `index-elimination` - selecting a subset of the entries in an index where the `term` is in the collection of `terms` in a search phrase.
* `postings` - a separate index that records which `documents` the `vocabulary` occurs in. In this implementation we also record the positions of each `term` in the `text` to create a positional inverted `index`.
* `postings list` - a record of the positions of a `term` in a `document`. A position of a `term` refers to the index of the `term` in an array that contains all the `terms` in the `text`.
* `term` - a word or phrase that is indexed from the `corpus`. The `term` may differ from the actual word used in the corpus depending on the `tokenizer` used.
* `text` - the indexable content of a `document`.
* `token` - representation of a `term` in a text source returned by a `tokenizer`. The token may include information about the `term` such as its position(s) in the text or frequency of occurrence.
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




