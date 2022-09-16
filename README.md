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

This library provides an interface and implementation classes that build and maintain an (inverted, positional) index for a collection of documents or `corpus` (see [definitions](#definitions)).

![Index construction flowchart](https://github.com/GM-Consult-Pty-Ltd/text_indexing/raw/main/assets/images/indexing.png?raw=true?raw=true "Index construction overview")

The [TextIndexer](#textindexer-interface) constructs two artifacts:
* a `dictionary` that holds the `vocabulary` of `terms` and the frequency of occurrence for each `term` in the `corpus`; and
* a `postings` map that holds a list of references to the `documents` for each `term` (the `postings list`). 

In this implementation, our `postings list` is a hashmap of the document id (`docId`) to maps that point to positions of the term in the document's fields. This allows query algorithms to score and rank search results based on the position(s) of a term in document fields.

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

For small collections, instantiate a [InMemoryIndexer](#inmemoryindexer-class), passing empty `Dictionary` and `Postings` hashmaps, then iterate over a collection of documents.

```dart
  // - initialize a [InMemoryIndexer]
  final indexer = InMemoryIndexer(dictionary: {}, postings: {});

  // - iterate through the sample data
  await Future.forEach(documents.entries, (MapEntry<String, String> doc) async {
    // - index each document
    await indexer.index(doc.key, doc.value);
  });
```

The [examples](https://pub.dev/packages/text_indexing/example) demonstrate the use of the [InMemoryIndexer](#inmemoryindexer-class) and [PersistedIndexer](#persistedindexer-class).

## API

The [API](https://pub.dev/documentation/text_indexing/latest/) exposes the [TextIndexer](#textindexer-interface) interface that builds and maintain an index for a collection of documents.

Three implementations of the [TextIndexer](#textindexer-interface) interface are provided:
* the [TextIndexerBase](#textindexerbase-class) abstract base class implements the `TextIndexer.index`, `TextIndexer.indexJson` and `TextIndexer.emit` methods;
* the [InMemoryIndexer](#inmemoryindexer-class) class is for fast indexing of a smaller corpus using in-memory dictionary and postings hashmaps; and
* the [PersistedIndexer](#persistedindexer-class) class, aimed at working with a larger corpus and asynchronous dictionaries and postings.

To maximise performance of the indexers the API manipulates nested hashmaps of DART core types `int` and `String` rather than defining strongly typed object models. To improve code legibility and maintainability the API makes use of [type aliases](#type-aliases) throughout.

### Type Aliases

* `Dictionary` is an alias for `Map<Term, Ft>`,  a hashmap of `Term` to `Ft`;
* `DictionaryEntry` is an alias for `MapEntry<Term, Ft>`, an entry in a `Dictionary`;
* `DocId` is an alias for `String`, used whenever a document id is referenced;
* `DocumentPostings` is an alias for `Map<DocId, FieldPostings>`, a hashmap of document ids to `FieldPostings`;
* `DocumentPostingsEntry` is an alias for `MapEntry<DocId, FieldPostings>`, an entry in a `DocumentPostings` hashmap;
* `FieldPostings` is an alias for `Map<FieldName, TermPositions>`, a hashmap of `FieldName`s to `TermPositions` in the field with `FieldName`;
* `FieldPostingsEntry` is an alias for `MapEntry<FieldName, TermPositions>`, an entry in a `FieldPostings` hashmap;
* `Ft` is an lias for `int` and denotes the frequency of a `Term` in an index or indexed object (the term frequency);
* `JSON` is an alias for `Map<String, dynamic>`, a hashmap known as `"Java Script Object Notation" (JSON)`, a common format for persisting data;
* `JsonCollection` is an alias for `Map<String, Map<String, dynamic>>`, a hashmap of `DocId` to `JSON` documents;
* `Pt` is an alias for `int`, used to denote the position of a `Term` in `SourceText` indexed object (the term position); and
* `TermPositions` is an alias for `List<Pt>`, an ordered `Set` of unique zero-based `Term` positions in `SourceText`, sorted in ascending order.

### TextIndexer Interface

The text indexing classes (indexers) in this library implement `TextIndexer`, an interface intended for information retrieval software applications. The design of the `TextIndexer` interface is consistent with [information retrieval theory](https://nlp.stanford.edu/IR-book/pdf/irbookonlinereading.pdf) and is intended to construct and/or maintain two artifacts:
* a hashmap with the vocabulary as key and the document frequency as the values (the `dictionary`); and
* another hashmap with the vocabulary as key and the postings lists for the linked `documents` as values (the `postings`).

The dictionary and postings can be asynchronous data sources or in-memory hashmaps.  The `TextIndexer` reads and writes to/from these artifacts using the `TextIndexer.loadTerms`, `TextIndexer.upsertDictionary`, `TextIndexer.loadTermPostings` and `TextIndexer.upsertTermPostings` asynchronous methods.

Text or documents can be indexed by calling the following methods:

* The `TextIndexer.indexJson` method indexes the fields in a `JSON` document, returning the `Postings` for the document.  The postings are also emitted by `TextIndexer.postingsStream`. 
* The `TextIndexer.index` method indexes text from a text document, returning the `Postings` for the document.  The postings are also emitted by `TextIndexer.postingsStream`.
* The `TextIndexer.indexCollection` method indexes text from a collection of `JSON `documents, emitting the `Postings` for each document in the `TextIndexer.postingsStream`.

The `TextIndexer.emit` method is called by `TextIndexer.index`, and adds an event to the `postingsStream`.

Listen to `TextIndexer.postingsStream` to handle the postings list emitted whenever a document is indexed.

Implementing classes override the following fields:
* `TextIndexer.tokenizer` is the `Tokenizer` instance used by the indexer to parse documents to tokens;
* `TextIndexer.postingsStream` emits a list of `DocumentPostingsEntry` instances whenever a document is indexed.

Implementing classes override the following asynchronous methods:
* `TextIndexer.index` indexes text from a document, returning a list of `DocumentPostingsEntry` and adding it to the `TextIndexer.postingsStream` by calling `TextIndexer.emit`;
* `emit` is called by index, and adds an event to the `postingsStream` after updating the dictionary and postings data stores;
* `TextIndexer.loadTerms` returns a `DictionaryTerm` map for a collection of terms from a dictionary;
* `TextIndexer.upsertDictionary` passes new or updated `DictionaryTerm` instances for persisting to a dictionary data store;
* `TextIndexer.loadTermPostings` returns a `PostingsEntry` map for a collection of terms from a postings source; and
* `TextIndexer.upsertTermPostings` passes new or updated `PostingsEntry` instances for upserting to a postings data store.

### TextIndexerBase Class

The `TextIndexerBase` is an abstract base class that implements the `TextIndexer.index` and `TextIndexer.emit` methods.  

Subclasses of `TextIndexerBase` may override the override `TextIndexerBase.emit` method to perform additional actions whenever a document is indexed.

### InMemoryIndexer Class

The `InMemoryIndexer` is a subclass of [TextIndexerBase](#textindexerbase-class) that builds and maintains in-memory dictionary and postings hashmaps. These hashmaps are updated whenever `InMemoryIndexer.emit` is called at the end of the `InMemoryIndexer.index` method, so awaiting a call to `InMemoryIndexer.index` will provide access to the updated `InMemoryIndexer.dictionary` and `InMemoryIndexer.postings` maps. 

The `InMemoryIndexer` is suitable for indexing a smaller corpus. An example of the use of `InMemoryIndexer` is included in the [examples](https://pub.dev/packages/text_indexing/example).

### PersistedIndexer Class

The `PersistedIndexer` is a subclass of [TextIndexerBase](#textindexerbase-class) that asynchronously reads and writes dictionary and postings data sources. These data sources are asynchronously updated whenever `PersistedIndexer.emit` is called by the `PersistedIndexer.index` method. 

The `PersistedIndexer` is suitable for indexing a large corpus but may incur some latency penalty and processing overhead. Consider running `PersistedIndexer` in an isolate to avoid slowing down the main thread.

An example of the use of `PersistedIndexer` is included in the package [examples](https://pub.dev/packages/text_indexing/example).

## Definitions

The following definitions are used throughout the [documentation](https://pub.dev/documentation/text_indexing/latest/):

* `corpus`- the collection of `documents` for which an `index` is maintained.
* `dictionary` - is a hash of `terms` (`vocabulary`) to the frequency of occurence in the `corpus` documents.
* `document` - a record in the `corpus`, that has a unique identifier (`docId`) in the `corpus`'s primary key and that contains one or more text fields that are indexed.
* `index` - an [inverted index](https://en.wikipedia.org/wiki/Inverted_index) used to look up `document` references from the `corpus` against a `vocabulary` of `terms`. The implementation in this package builds and maintains a positional inverted index, that also includes the positions of the indexed `term` in each `document`.
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




