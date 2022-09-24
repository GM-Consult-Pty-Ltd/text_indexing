<!-- 
BSD 3-Clause License
Copyright (c) 2022, GM Consult Pty Ltd, All rights reserved. 
-->

[![GM Consult Pty Ltd](https://raw.githubusercontent.com/GM-Consult-Pty-Ltd/text_indexing/main/assets/images/text_indexing_header.png?raw=true "GM Consult Pty Ltd")](https://github.com/GM-Consult-Pty-Ltd)
## **Dart library for creating an inverted index on a collection of text documents.**

*THIS PACKAGE IS **PRE-RELEASE**, IN ACTIVE DEVELOPMENT AND SUBJECT TO DAILY BREAKING CHANGES.*

Skip to section:
- [Overview](#overview)
- [Usage](#usage)
- [API](#api)
- [Definitions](#definitions)
- [References](#references)
- [Issues](#issues)

## Overview

This library provides interfaces and implementation classes that build and maintain a (positional, zoned) [inverted index](#invertedindex) for a collection of documents or `corpus` (see [definitions](#definitions)).

![Index construction flowchart](https://github.com/GM-Consult-Pty-Ltd/text_indexing/raw/main/assets/images/indexing.png?raw=true?raw=true "Index construction overview")

The [indexer](#textindexer) uses a `tokenizer` to construct three artifacts:
* the `dictionary` holds the `vocabulary` of `terms` and the frequency of occurrence for each `term` in the `corpus`; 
* the `k-gram index` maps `k-grams` to `terms` in the `dictionary`; and
* the `postings` index holds a list of references to the `documents` for each `term` (`postings list`). The `postings list` includes the positions of the `term` in the document's `zones` (fields), making the `postings` a `positional, zoned inverted index`.

![Index artifacts](https://github.com/GM-Consult-Pty-Ltd/text_indexing/raw/main/assets/images/index_artifacts.png?raw=true?raw=true "Components of inverted positional index")

Refer to the [references](#references) to learn more about information retrieval systems and the theory behind this library.

## Performance

A sample data set consisting of stock data for the U.S. markets was used to benchmark performance of  [TextIndexer](#textindexer) and [InvertedIndex](#invertedindex) implementations. The data set contains 20,770 JSON documents with basic information on each stock and the JSON data file is 22MB in size.

For the benchmarking tests we created an implementation [InvertedIndex](#invertedindex) class that uses [Hive](https://pub.dev/packages/hive) as local storage ([HiveIndex](https://github.com/GM-Consult-Pty-Ltd/text_indexing/tree/main/test)), and benchmarked that against [InMemoryIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/InMemoryIndex-class.html). Both indexes were given the same phrase length (2), k-gram length (3) and zones `('name', 'symbol', 'ticker', 'description', 'hashTag')`.

Benchmarking was performed as part of unit tests in the VS Code IDE on a Windows 10 workstation with an Intel(R) Core(TM) i9-7900X CPU running at 3.30GHz and 64GB of DDR4-2666 RAM.

### Indexing the corpus

The typical times taken by [TextIndexer](#textindexer) to index our sample dataset to 243,700 terms and 18,276 k-grams using [InMemoryIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/InMemoryIndex-class.html) vs [HiveIndex](https://github.com/GM-Consult-Pty-Ltd/text_indexing/tree/main/test) is shown below.

| InvertedIndex                 |   Elapsed time | Per document | 
|-------------------------------|----------------|--------------|
| InMemoryIndex                 |    ~15 seconds |      0.68 mS |
| HiveIndex                     |    ~41 minutes |       112 mS |

Building the index while holding all the index artifacts in memory is 165 times faster than placing them in a [Hive](https://pub.dev/packages/hive) box (a relatively fast local storage option).

If memory and the size of the corpus allows, [InMemoryIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/InMemoryIndex-class.html) is a clear winner. The memory required for the `postings`, in particular, may not make this practical for larger document collections. The [AsyncCallbackIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/AsyncCallbackIndexclass.html) class provides the flexibility to access each of the three index hashmaps from a different data source, so implementing applications can, for example, hold the `dictionary` and `k-gram` index in memory, with the `postings` in local storage or implement in-memory caching.

Regardless of the [InvertedIndex](#invertedindex) implementation, applications should avoid running the [TextIndexer](#textindexer) in the same thread as the the user interface to avoid UI "jank". 

The `dictionary`, `k-gram index` and `postings` are 8MB, 41MB and 362MB in size, respectively, for our sample index of 243,700 terms and 18,276 k-grams.

### Querying the indexes

Having created a persisted index on our sample data set, we ran a query on a search phrase of 9 terms we know are present in the sample data. The query requires a few round trips to each of the three indexes to match the terms, calculate the `inverse document term frequencies` etc. The elapsed time for retrieving the data from the [InMemoryIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/InMemoryIndex-class.html) vs [HiveIndex](https://github.com/GM-Consult-Pty-Ltd/text_indexing/tree/main/test) is shown below.

| InvertedIndex                 |   Elapsed time | 
|-------------------------------|----------------|
| InMemoryIndex                 |         ~22 mS |
| HiveIndex                     |        ~205 mS |

As expected, the [InMemoryIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/InMemoryIndex-class.html) is quicker, but the differences are unlikely to be material in a real-world application, even for predictive text or auto-correct applications.

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

For small collections, instantiate a [TextIndexer](https://pub.dev/documentation/text_indexing/latest/text_indexing/TextIndexer-class.html)  with a [InMemoryIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/InMemoryIndex-class.html), (optionally passing empty `Dictionary` and `Postings` hashmaps). 

Call the [TextIndexer.indexCollection](https://pub.dev/documentation/text_indexing/latest/text_indexing/TextIndexer/indexCollection.html) method to a a collection of documents to the index.

```dart
    // initialize an in=memory index for a JSON collection with two indexed fields
    final myIndex = InMemoryIndex(zones: {'name': 1.0, 'description': 0.5}, phraseLength: 2);

    // - initialize a `TextIndexer`, passing in the index
    final indexer =TextIndexer(index: myIndex);

    // - index the json collection `documents`
    await indexer.indexCollection(documents);
  
```

The [examples](https://pub.dev/packages/text_indexing/example) demonstrate the use of the [TextIndexer](https://pub.dev/documentation/text_indexing/latest/text_indexing/TextIndexer-class.html) with a [InMemoryIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/InMemoryIndex-class.html) and [AsyncCallbackIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/AsyncCallbackIndex-class.html).

## API

The [API](https://pub.dev/documentation/text_indexing/latest/) exposes the [TextIndexer](https://pub.dev/documentation/text_indexing/latest/text_indexing/TextIndexer-class.html) interface that builds and maintains an [InvertedIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/InvertedIndex-class.html) for a collection of documents.

To maximise performance of the indexers the API performs lookups in nested hashmaps of DART core types. To improve code legibility the API makes use of [type aliases](https://pub.dev/documentation/text_indexing/latest/text_indexing/text_indexing-library.html#typedefs) throughout.

### InvertedIndex

The [InvertedIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/InvertedIndex-class.html) interface exposes properties and methods for working with [Dictionary](https://pub.dev/documentation/text_indexing/latest/text_indexing/Dictionary.html), [KGramIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/KGramIndex.html) and [Postings](https://pub.dev/documentation/text_indexing/latest/text_indexing/Postings.html) hashmaps.  

A [mixin class](https://pub.dev/documentation/text_indexing/latest/text_indexing/InvertedIndexMixin-class.html) implements the [getTfIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/InvertedIndex/getTfIndex.html), [getFtdPostings](https://pub.dev/documentation/text_indexing/latest/text_indexing/InvertedIndex/getFtdPostings.html) and [getIdFtIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/InvertedIndex/getIdFtIndex.html) methods.

Two implementation classes are provided: 
 * the [InMemoryIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/InMemoryIndex-class.html) class is intended for fast indexing of a smaller corpus using in-memory dictionary, k-gram and postings hashmaps; and
 * the [AsyncCallbackIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/AsyncCallbackIndex-class.html) is intended for working with a larger corpus.  It uses asynchronous callbacks to perform read and write operations on `dictionary`, `k-gram` and `postings` repositories.

#### Phrase length

`InvertedIndex.phraseLength` is the maximum length of phrases in the index vocabulary.

The minimum `phraseLength` is 1. If phrase length is greater than 1, the index also contains phrases up to `phraseLength` words long, concatenated from consecutive `terms`. The index size is increased by a factor of `phraseLength`. The `phraseLength` default is 1 for [InMemoryIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/InMemoryIndex-class.html) and [AsyncCallbackIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/AsyncCallbackIndex-class.html).

#### Zones

`InvertedIndex.zones` is a hashmap of zone names to their relative weight in the index.

If `zones` is empty, all the text fields of the collection will be indexed, which may increase the size of the index significantly.

#### K-gram length (k)

`InvertedIndex.k` is the length of k-gram entries in the k-gram index.

The preferred k-gram length is `3, or a tri-gram`. This results in a good compromise between the length of the k-gram index and search efficiency.

### TextIndexer

[TextIndexer](https://pub.dev/documentation/text_indexing/latest/text_indexing/TextIndexer-class.html) is an interface for classes that construct and maintain a [InvertedIndex](#invertedindex).

Text or documents can be indexed by calling the following methods:
* [indexText](https://pub.dev/documentation/text_indexing/latest/text_indexing/TextIndexer/indexText.html) indexes text;
* [indexJson](https://pub.dev/documentation/text_indexing/latest/text_indexing/TextIndexer/indexJson.html) indexes the fields in a `JSON` document; and 
* [indexCollection](https://pub.dev/documentation/text_indexing/latest/text_indexing/TextIndexer/indexCollection.html) indexes the fields of all the documents in a JSON document collection.

Use the unnamed factory constructor to instantiate a [TextIndexer](https://pub.dev/documentation/text_indexing/latest/text_indexing/TextIndexer-class.html) with the index of your choice, or extend [TextIndexerBase](https://pub.dev/documentation/text_indexing/latest/text_indexing/TextIndexerBase-class.html).

## Definitions

The following definitions are used throughout the [documentation](https://pub.dev/documentation/text_indexing/latest/):

* `corpus`- the collection of `documents` for which an `index` is maintained.
* `character filter` - filters characters from text in preparation of tokenization.  
* `dictionary` - is a hash of `terms` (`vocabulary`) to the frequency of occurence in the `corpus` documents.
* `document` - a record in the `corpus`, that has a unique identifier (`docId`) in the `corpus`'s primary key and that contains one or more text fields that are indexed.
* `index` - an [inverted index](https://en.wikipedia.org/wiki/Inverted_index) used to look up `document` references from the `corpus` against a `vocabulary` of `terms`. 
* `document frequency (dFt)` is number of documents in the `corpus` that contain a term.
* `index-elimination` - selecting a subset of the entries in an index where the `term` is in the collection of `terms` in a search phrase.
* `inverse document frequency` or `iDft` is equal to log (N / `dft`), where N is the total number of terms in the index. The `IdFt` of a rare term is high, whereas the [IdFt] of a frequent term is likely to be low. 
* `JSON` is an acronym for `"Java Script Object Notation"`, a common format for persisting data.
`k-gram` - a sequence of (any) k consecutive characters from a `term`. A k-gram can start with "$", dentoting the start of the [Term], and end with "$", denoting the end of the [Term]. The 3-grams for "castle" are { $ca, cas, ast, stl, tle, le$ }.
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
* `token filter` - returns a subset of `tokens` from the tokenizer output.
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




