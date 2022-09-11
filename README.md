<!-- 
BSD 3-Clause License
Copyright (c) 2022, GM Consult Pty Ltd
All rights reserved. 
-->

# text_indexing

Dart library for creating an inverted index on a collection of text documents.

*THIS PACKAGE IS IN BETA DEVELOPMENT AND SUBJECT TO DAILY BREAKING CHANGES.*

## Install

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  text_indexing: ^0.0.1-beta.2
```

In your code file add the following import:

```dart
import 'package:text_indexing/text_indexing.dart';
```

## Usage

The text indexing classes (indexers) in this library are intended for information retrieval software applications. The implementation is consistent with [information retrieval theory](https://nlp.stanford.edu/IR-book/pdf/irbookonlinereading.pdf).

The objective is to build and maintain:
* a term dictionary that holds the vocabulary of terms and the frequency of occurrence for each term in the corpus; and
* a postings map that holds the references to the documents for each term. In this implementation, our postings include the positions of the term in the document to allow search algorithms to derive relevance.

The `Indexer` is a base class that provides an `Indexer.index` method that indexes a document, adding a list of term positions to the `Indexer.postingsStream` for the document.  Subclasses of `Indexer` may override the override `Indexer.emit` method to perform additional actions whenever a document is indexed, e.g. updating a term dictionary or postings list.

The `InMemoryIndexer` is a subclass of `Indexer` that builds and maintains in-memory `TermDictionary` and `PostingMap` hashmaps. These hashmaps are updated whenever `InMemoryIndexer.emit` is called at the end of the `InMemoryIndexer.index` method, so awaiting a call to `InMemoryIndexer.index` will provide access to the updated `InMemoryIndexer.dictionary` and
`InMemoryIndexer.postings` collections. The `InMemoryIndexer` is suitable for indexing and searching smaller collections. An example of the use of `InMemoryIndexer` is included in the package [examples](https://pub.dev/packages/text_indexing/example);

## Issues

If you find a bug please fill an [issue](https://github.com/GM-Consult-Pty-Ltd/text_indexing/issues).  

This project is a supporting package for a revenue project that has priority call on resources, so please be patient if we don't respond immediately to issues or pull requests.


