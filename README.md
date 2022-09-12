<!-- 
BSD 3-Clause License
Copyright (c) 2022, GM Consult Pty Ltd
All rights reserved. 
-->

# text_indexing

Dart library for creating an inverted index on a collection of text `document`s.

*THIS PACKAGE IS **PRE-RELEASE** AND SUBJECT TO DAILY BREAKING CHANGES.*

### Objective

The objective of this package is to provide an interface and implementation classes that build and maintain  a `term` `dictionary` that holds the `vocabulary` of `term`s and the frequency of occurrence for each `term` in the `corpus` and a `postings` map that holds the references to the `document`s for each `term`. In this implementation, our `postings` include the positions of the `term` in the `document`s to allow search algorithms to derive relevance on a per `document` basis.

### Definitions

The following definitions are used throughout the [documentation](https://pub.dev/documentation/text_indexing/latest/):

* `corpus`- the collection of `document`s for which an `index` is maintained.
* `dictionary` - is a hash of `term`s (`vocabulary`) to the frequency of occurence in the `corpus` `document`s. In this implementation, `Dictionary` is a type defintion for a hashmap with the `vocabulary` as key and the `document` frequency as the values.
* `document` - a record in the `corpus`, that has a unique identifier (`docId`) in the `corpus`'s primary key and that contains one or more text fields that are indexed.
* `index` - an [inverted index](https://en.wikipedia.org/wiki/Inverted_index) used to look up `document` references from the `corpus` against a `vocabulary` of `term`s. The implementation in this package builds and maintains a positional inverted index, that also includes the positions of the indexed `term` in each `document`.
* `postings` - a separate index that records which `document`s the `vocabulary` occurs in. In this implementation we also record the positions of each `term` in the `document` to create a positional inverted `index`.
* `postings list` - a record of the positions of a `term` in a `document`. A position of a `term` refers to the index of the `term` in an array that contains all the `term`s in the `text`.
* `term` - a word or phrase that is indexed from the `corpus`. The `term` may differ from the actual word used in the corpus depending on the `tokenizer` used.
* `text` - the indexable content of a `document`.
* `token` - representation of a `term` in a text source returned by a `tokenizer`. The token may include information about the `term` such as its position(s) in the text or frequency of occurrence.
* `tokenizer` - a function that returns a collection of `token`s from `text`, after applying a character filter, `term` filter, [stemmer](https://en.wikipedia.org/wiki/Stemming) and / or [lemmatizer](https://en.wikipedia.org/wiki/Lemmatisation).
* `vocabulary` is the collection of `term`s/words indexed from the `corpus`.

## Interface

The text indexing classes (indexers) in this library inherit from `TextIndexer`, an interface intended for information retrieval software applications. The `TextIndexer` interface is consistent with [information retrieval theory](https://nlp.stanford.edu/IR-book/pdf/irbookonlinereading.pdf).

The inverted `index` is comprised of two artifacts:
* a `Dictionary` is a hashmap of `DictionaryEntry`s with the `vocabulary` as key and the `document` frequency as the values; and
* a `Postings` a hashmap of `PostingsEntry`s with the `vocabulary` as key and the `postings list`s for the linked `document`s as values.

The `Dictionary` and `Postings` can be asynchronous data sources or in-memory hashmaps.  The `TextIndexer` reads and writes to/from these artifacts using the `loadTerms`, `updateDictionary`, `loadTermPostings` and `upsertTermPostings` asynchronous methods.

The `index` method indexes `text` from a `document`, returning a list of `PostingsList` that is also emitted by `postingsStream`. The `index` method calls `emit`, passing the list of `PostingsList`.

The `emit` method is called by `index`, and adds an event to the `postingsStream`.

Listen to `postingsStream` to update your `dictionary` and `postings` map.

Implementing classes override the following fields:
* `Tokenizer` is the `Tokenizer` instance used by the indexer to parse `document`s to tokens;
* `postingsStream` emits a list of `PostingsList` instances whenever a `document` is indexed.

Implementing classes override the following asynchronous methods:
* `index` indexes `text` from a `document`, returning a list of `PostingsList` and adding it to the `postingsStream` by calling `emit`;
* `emit` is called by `index`, and adds an event to the `postingsStream` after updating the `Dictionary` and `Postings`;
* `loadTerms` returns a `Dictionary` for a `vocabulary` from a `Dictionary`;
* `updateDictionary` passes new or updated `DictionaryEntry` instances for persisting to a `Dictionary`;
* `loadTermPostings` returns `PostingsEntry` entities for a `vocabulary` from `Postings`; and
* `upsertTermPostings` passes new or updated `PostingsEntry` instances for upserting to `Postings`.

### References

* [Manning, Raghavan and Schütze, "*Introduction to Information Retrieval*", Cambridge University Press. 2008](https://nlp.stanford.edu/IR-book/pdf/irbookprint.pdf)
* [University of Cambridge, 2016 "*Information Retrieval*", course notes, Dr Ronan Cummins](https://www.cl.cam.ac.uk/teaching/1516/InfoRtrv/)
* [Wikipedia (1), "*Inverted Index*", from Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Inverted_index)
* [Wikipedia (2), "*Lemmatisation*", from Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Lemmatisation)
* [Wikipedia (3), "*Stemming*", from Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Stemming)

## Install

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  text_indexing: ^0.0.1
```

In your code file add the following import:

```dart
import 'package:text_indexing/text_indexing.dart';
```

## Usage

[Examples](https://pub.dev/packages/text_indexing/example) are provided for the `InMemoryIndexer` and `PersistedIndexer`, two implementations of the `TextIndexer` interface that inherit from `TextIndexerBase`.

### `TextIndexerBase` Class

The `TextIndexerBase` is an abstract base class that implements the `TextIndexer.index` and `TextIndexer.emit` methods.  

Subclasses of `TextIndexerBase` may override the override `TextIndexerBase.emit` method to perform additional actions whenever a `document` is indexed.

### `InMemoryIndexer` Class

The `InMemoryIndexer` is a subclass of `TextIndexerBase` that builds and maintains in-memory `Dictionary` and `PostingMap` hashmaps. These hashmaps are updated whenever `InMemoryIndexer.emit` is called at the end of the `InMemoryIndexer.index` method, so awaiting a call to `InMemoryIndexer.index` will provide access to the updated `InMemoryIndexer.dictionary` and `InMemoryIndexer.postings` collections. 

The `InMemoryIndexer` is suitable for indexing a smaller `corpus`. An example of the use of `InMemoryIndexer` is included in the [examples](https://pub.dev/packages/text_indexing/example).

### `PersistedIndexer` Class

The `PersistedIndexer` is a subclass of `TextIndexerBase` that asynchronously reads and writes `dictionary` and `postings` data sources. These data sources are asynchronously updated whenever `PersistedIndexer.emit` is called by the `PersistedIndexer.index` method. 

The `PersistedIndexer` is suitable for indexing and searching a large corpus but may incur some latency penalty and processing overhead. An example of the use of `PersistedIndexer` is included in the package [examples](https://pub.dev/packages/text_indexing/example).

## Issues

If you find a bug please fill an [issue](https://github.com/GM-Consult-Pty-Ltd/text_indexing/issues).  

This project is a supporting package for a revenue project that has priority call on resources, so please be patient if we don't respond immediately to issues or pull requests.


