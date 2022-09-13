<!-- 
BSD 3-Clause License
Copyright (c) 2022, GM Consult Pty Ltd
All rights reserved. 
-->

# text_indexing

Dart library for creating an inverted index on a collection of text documents.

*THIS PACKAGE IS **PRE-RELEASE**, IN ACTIVE DEVELOPMENT AND SUBJECT TO DAILY BREAKING CHANGES.*

## Objective

The objective of this package is to provide an interface and implementation classes that build and maintain an index for a collection of documents (`corpus`).

![Index construction flowchart](https://github.com/GM-Consult-Pty-Ltd/text_indexing/raw/main/assets/images/indexing.png?raw=true?raw=true "Index construction overview")

The `TextIndexer` constructs two artifacts:
* a `dictionary` that holds the `vocabulary` of `terms` and the frequency of occurrence for each `term` in the `corpus`; and
* a `postings` map that holds a list of references to the `documents` for each `term` (the `postings list`). 

In this implementation, our `postings list` is a hashmap of the document id (`docId`) to an ordered list of the `positions` of the `term` in the document to allow query algorithms to score and rank search results based on the position(s) of a term in the results.

![Index artifacts](https://github.com/GM-Consult-Pty-Ltd/text_indexing/raw/main/assets/images/index_artifacts.png?raw=true?raw=true "Index construction overview")

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

## Interface

The text indexing classes (indexers) in this library inherit from `TextIndexer`, an interface intended for information retrieval software applications. The design of the `TextIndexer` interface is consistent with [information retrieval theory](https://nlp.stanford.edu/IR-book/pdf/irbookonlinereading.pdf) and is intended to construct and/or maintain two artifacts:
* a hashmap with the vocabulary as key and the document frequency as the values (the `dictionary`); and
* another hashmap with the vocabulary as key and the postings lists for the linked `documents` as values (the `postings`).

The dictionary and postings can be asynchronous data sources or in-memory hashmaps.  The `TextIndexer` reads and writes to/from these artifacts using the `TextIndexer.loadTerms`, `TextIndexer.updateDictionary`, `TextIndexer.loadTermPostings` and `TextIndexer.upsertTermPostings` asynchronous methods.

The `TextIndexer.index` method indexes text from a document, returning a list of `PostingsList` that is also emitted by `TextIndexer.postingsStream`. The `TextIndexer.index` method calls `TextIndexer.emit`, passing the list of `PostingsList`.

The `TextIndexer.emit` method is called by `TextIndexer.index`, and adds an event to the `postingsStream`.

Listen to `TextIndexer.postingsStream` to handle the postings list emitted whenever a document is indexed.

Implementing classes override the following fields:
* `TextIndexer.tokenizer` is the `Tokenizer` instance used by the indexer to parse documents to tokens;
* `TextIndexer.postingsStream` emits a list of `PostingsList` instances whenever a document is indexed.

Implementing classes override the following asynchronous methods:
* `TextIndexer.index` indexes text from a document, returning a list of `PostingsList` and adding it to the `TextIndexer.postingsStream` by calling `TextIndexer.emit`;
* `emit` is called by index, and adds an event to the `postingsStream` after updating the dictionary and postings data stores;
* `TextIndexer.loadTerms` returns a `DictionaryTerm` map for a collection of terms from a dictionary;
* `TextIndexer.updateDictionary` passes new or updated `DictionaryTerm` instances for persisting to a dictionary data store;
* `TextIndexer.loadTermPostings` returns a `PostingsEntry` map for a collection of terms from a postings source; and
* `TextIndexer.upsertTermPostings` passes new or updated `PostingsEntry` instances for upserting to a postings data store.

## Implementations

Three implementations of the `TextIndexer` interface are provided:
* the `TextIndexerBase` abstract base class implements the `TextIndexer.index` and `TextIndexer.emit` methods;
* the `InMemoryIndexer` class is for fast indexing of a smaller corpus using in-memory dictionary and postings hashmaps; and
* the `PersistedIndexer` class, aimed at working with a larger corpus and asynchronous dictionaries and postings.


### `TextIndexerBase` Class

The `TextIndexerBase` is an abstract base class that implements the `TextIndexer.index` and `TextIndexer.emit` methods.  

Subclasses of `TextIndexerBase` may override the override `TextIndexerBase.emit` method to perform additional actions whenever a document is indexed.

### `InMemoryIndexer` Class

The `InMemoryIndexer` is a subclass of `TextIndexerBase` that builds and maintains in-memory dictionary and postings hashmaps. These hashmaps are updated whenever `InMemoryIndexer.emit` is called at the end of the `InMemoryIndexer.index` method, so awaiting a call to `InMemoryIndexer.index` will provide access to the updated `InMemoryIndexer.dictionary` and `InMemoryIndexer.postings` maps. 

The `InMemoryIndexer` is suitable for indexing a smaller corpus. An example of the use of `InMemoryIndexer` is included in the [examples](https://pub.dev/packages/text_indexing/example).

### `PersistedIndexer` Class

The `PersistedIndexer` is a subclass of `TextIndexerBase` that asynchronously reads and writes dictionary and postings data sources. These data sources are asynchronously updated whenever `PersistedIndexer.emit` is called by the `PersistedIndexer.index` method. 

The `PersistedIndexer` is suitable for indexing a large corpus but may incur some latency penalty and processing overhead. Consider running `PersistedIndexer` in an isolate to avoid slowing down the main thread.

An example of the use of `PersistedIndexer` is included in the package [examples](https://pub.dev/packages/text_indexing/example).

## Usage

### Install

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  text_indexing: <latest version>
```

In your code file add the following import:

```dart
import 'package:text_indexing/text_indexing.dart';
```

### Examples

[Examples](https://pub.dev/packages/text_indexing/example) are provided for the `InMemoryIndexer` and `PersistedIndexer`, two implementations of the `TextIndexer` interface that inherit from `TextIndexerBase`.

## Issues

If you find a bug please fill an [issue](https://github.com/GM-Consult-Pty-Ltd/text_indexing/issues).  

This project is a supporting package for a revenue project that has priority call on resources, so please be patient if we don't respond immediately to issues or pull requests.

## References

* [Manning, Raghavan and Schütze, "*Introduction to Information Retrieval*", Cambridge University Press, 2008](https://nlp.stanford.edu/IR-book/pdf/irbookprint.pdf)
* [University of Cambridge, 2016 "*Information Retrieval*", course notes, Dr Ronan Cummins, 2016](https://www.cl.cam.ac.uk/teaching/1516/InfoRtrv/)
* [Wikipedia (1), "*Inverted Index*", from Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Inverted_index)
* [Wikipedia (2), "*Lemmatisation*", from Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Lemmatisation)
* [Wikipedia (3), "*Stemming*", from Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Stemming)




