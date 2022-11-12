<!-- 
BSD 3-Clause License
Copyright (c) 2022, GM Consult Pty Ltd, All rights reserved. 
-->

[![GM Consult Pty Ltd](https://raw.githubusercontent.com/GM-Consult-Pty-Ltd/text_indexing/main/dev/images/text_indexing_header.v2.png?raw=true "GM Consult Pty Ltd")](https://github.com/GM-Consult-Pty-Ltd/text_indexing/)
## **Create an inverted index on a collection of text documents.**

*THIS PACKAGE IS **PRE-RELEASE** AND SUBJECT TO DAILY BREAKING CHANGES.*

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
* the `k-gram index` maps `k-grams` to `terms` in the `dictionary`; 
* the `keyword postings` index maps the keywords in the corpus to document references with the keyword score for the keyword in that document; and
* the `postings` index holds a list of references to the `documents` for each `term` (`postings list`). The `postings list` includes the positions of the `term` in the document's `zones` (fields), making the `postings` a `positional, zoned inverted index`.

![Index artifacts](https://github.com/GM-Consult-Pty-Ltd/text_indexing/raw/main/assets/images/index_artifacts.png?raw=true?raw=true "Components of inverted positional index")

Refer to the [references](#references) to learn more about information retrieval systems and the theory behind this library.

(*[back to top](#)*)

## Performance

A sample data set consisting of stock data for the U.S. markets was used to benchmark performance of  [TextIndexer](#textindexer) and [InvertedIndex](#invertedindex) implementations. The data set contains 20,770 JSON documents with basic information on each stock and the JSON data file is 22MB in size.

For the benchmarking tests we created an implementation [InvertedIndex](#invertedindex) class that uses [Hive](https://pub.dev/packages/hive) as local storage and benchmarked that against [InMemoryIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/InMemoryIndex-class.html). Both indexes were given the same phrase length (2), k-gram length (2) and zones `('name', 'symbol', 'ticker', 'description', 'hashTag')`.

Benchmarking was performed as part of unit tests in the VS Code IDE on a Windows 10 workstation with an Intel(R) Core(TM) i9-7900X CPU running at 3.30GHz and 64GB of DDR4-2666 RAM.

### Indexing the corpus

The typical times taken by [TextIndexer](#textindexer) to index our sample dataset to 243,700 terms and 18,276 k-grams using [InMemoryIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/InMemoryIndex-class.html) vs the Hive-based index is shown below.

| InvertedIndex                 |   Elapsed time | Per document | 
|-------------------------------|----------------|--------------|
| InMemoryIndex                 |    ~15 seconds |      0.68 mS |
| Hive-based Index              |    ~41 minutes |       112 mS |

Building the index while holding all the index artifacts in memory is 165 times faster than placing them in a [Hive](https://pub.dev/packages/hive) box (a relatively fast local storage option).

If memory and the size of the corpus allows, [InMemoryIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/InMemoryIndex-class.html) is a clear winner. The memory required for the `postings`, in particular, may not make this practical for larger document collections. The [AsyncCallbackIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/AsyncCallbackIndexclass.html) class provides the flexibility to access each of the three index hashmaps from a different data source, so implementing applications can, for example, hold the `dictionary` and `k-gram` indexes in memory, with the `postings` in local storage. Alternatively in-memory caching may also provide performance improvements for a corpus with many repeated terms.

Regardless of the [InvertedIndex](#invertedindex) implementation, applications should avoid running the [TextIndexer](#textindexer) in the same thread as the user interface to avoid UI "jank". 

The `dictionary`, `k-gram index` and `postings` are 8MB, 41MB and 362MB in size, respectively, for our sample index of 243,700 terms and 18,276 k-grams.

### Querying the indexes

Having created a persisted index on our sample data set, we ran a query on a search phrase of 9 terms we know are present in the sample data. The query requires a few round trips to each of the three indexes to match the terms, calculate the `inverse document term frequencies` etc. The elapsed time for retrieving the data from the [InMemoryIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/InMemoryIndex-class.html) vs the Hive-based index is shown below.

| InvertedIndex                 |   Elapsed time | 
|-------------------------------|----------------|
| InMemoryIndex                 |         ~22 mS |
| Hive-based Index              |        ~205 mS |

As expected, the [InMemoryIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/InMemoryIndex-class.html) is quicker than the Hive-based index, but the differences are unlikely to be material in a real-world application, even for predictive text or auto-correct applications.

(*[back to top](#)*)

## Usage

In the `pubspec.yaml` of your flutter project, add the `text_indexing` dependency.

```yaml
dependencies:
  text_indexing: <latest version>
```

In your code file add the `text_indexing` import.

```dart
// import the core classes
import 'package:text_indexing/text_indexing.dart'; 

// import the typedefs, if needed
import 'package:text_indexing/type_definitions.dart'; 

// import the extensions, if needed
import 'package:text_indexing/extensions.dart'; 
```

For small collections, instantiate a [TextIndexer](https://pub.dev/documentation/text_indexing/latest/text_indexing/TextIndexer-class.html)  with a [InMemoryIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/InMemoryIndex-class.html), (optionally passing empty `Dictionary` and `Postings` hashmaps). 

Call the [TextIndexer.indexCollection](https://pub.dev/documentation/text_indexing/latest/text_indexing/TextIndexer/indexCollection.html) method to a a collection of documents to the index.

```dart
    // initialize an in=memory index for a JSON collection with two indexed fields
    final myIndex = InMemoryIndex(
        zones: {'name': 1.0, 'description': 0.5}, 
        nGramRange: NGramRange(1, 2));

    // - initialize a `TextIndexer`, passing in the index
    final indexer =TextIndexer(index: myIndex);

    // - index the json collection `documents`
    await indexer.indexCollection(documents);
  
```

The [examples](https://pub.dev/packages/text_indexing/example) demonstrate the use of the [TextIndexer](https://pub.dev/documentation/text_indexing/latest/text_indexing/TextIndexer-class.html) with a [InMemoryIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/InMemoryIndex-class.html) and [AsyncCallbackIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/AsyncCallbackIndex-class.html).

(*[back to top](#)*)

## API

The [API](https://pub.dev/documentation/text_indexing/latest/) exposes the [TextIndexer](https://pub.dev/documentation/text_indexing/latest/text_indexing/TextIndexer-class.html) interface that builds and maintains an [InvertedIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/InvertedIndex-class.html) for a collection of documents.

To maximise performance of the indexers the API performs lookups in nested hashmaps of DART core types.

The API contains a fair amount of boiler-plate, but we aim to make the code as readable, extendable and re-usable as possible:
* We use an `interface > implementation mixin > base-class > implementation class pattern`:
  - the `interface` is an abstract class that exposes fields and methods but contains no implementation code. The `interface` may expose a factory constructor that returns an `implementation class` instance;
  - the `implementation mixin` implements the `interface` class methods, but not the input fields;
  - the `base-class` is an abstract class with the `implementation mixin` and exposes a default, unnamed generative const constructor for sub-classes. The intention is that `implementation classes` extend the `base class`, overriding the `interface` input fields with final properties passed in via a const generative constructor; and
  - the class naming convention for this pattern is `"Interface" > "InterfaceMixin" > "InterfaceBase"`.
* To improve code legibility the API makes use of type aliases, callback function definitions and extensions. The typedefs and extensions are not exported by the [text_indexing](https://pub.dev/documentation/text_indexing/latest/text_indexing/text_indexing-library.html) library, but can be found in the [type_definitions](https://pub.dev/documentation/text_indexing/latest/type_definitions/type_definitions-library.html) and [extensions](https://pub.dev/documentation/text_indexing/latest/extensions/extensions-library.html) mini-libraries. [Import these libraries seperately](#usage) if needed.

### InvertedIndex

The [InvertedIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/InvertedIndex-class.html) interface exposes properties and methods for working with [Dictionary](https://pub.dev/documentation/text_indexing/latest/text_indexing/Dictionary.html), [KGramIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/KGramIndex.html) and [Postings](https://pub.dev/documentation/text_indexing/latest/text_indexing/Postings.html) hashmaps.  

Two implementation classes are provided: 
 * the [InMemoryIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/InMemoryIndex-class.html) class is intended for fast indexing of a smaller corpus using in-memory dictionary, k-gram and postings hashmaps; and
 * the [AsyncCallbackIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/AsyncCallbackIndex-class.html) is intended for working with a larger corpus.  It uses asynchronous callbacks to perform read and write operations on `dictionary`, `k-gram` and `postings` repositories.

#### N-Gram Range

`InvertedIndex.nGramRange` is the range of N-gram lengths to generate. The minimum  n-gram length is 1.

If n-gram length is greater than 1, the  index vocabulary also contains n-grams up to `nGramRange.max` long, concatenated from consecutive terms. The index size is increased by a factor of`[nGramRange.max`. The `nGramRange` default is `NGramRange(1,2)` for [InMemoryIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/InMemoryIndex-class.html) and [AsyncCallbackIndex](https://pub.dev/documentation/text_indexing/latest/text_indexing/AsyncCallbackIndex-class.html).

#### Zones

`InvertedIndex.zones` is a hashmap of zone names to their relative weight in the index.

If `zones` is empty, all the text fields of the collection will be indexed, which may increase the size of the index significantly.

#### K-gram length (k)

`InvertedIndex.k` is the length of k-gram entries in the k-gram index.

The preferred k-gram length is `3, or a tri-gram`. This results in a good compromise between the length of the k-gram index and search efficiency.

#### Tokenizing Strategy (k)

`InvertedIndex.strategy` is the tokenizing strategy to use when tokenizing documents for the postings index:
* select `TokenizingStrategy.terms` to minimize the index size;
* select `TokenizingStrategy.nGrams` to add n-grams (phrases) in the desired [range](#n-gram-range);
* select `TokenizingStrategy.keyWords` to add keyword phrases of unlimited length as well as n-grams;
* select `TokenizingStrategy.all` to add terms, n-grams and keyWords;

### TextIndexer

[TextIndexer](https://pub.dev/documentation/text_indexing/latest/text_indexing/TextIndexer-class.html) is an interface for classes that construct and maintain a [InvertedIndex](#invertedindex).

Text or documents can be indexed by calling the following methods:
* [indexText](https://pub.dev/documentation/text_indexing/latest/text_indexing/TextIndexer/indexText.html) indexes text;
* [indexJson](https://pub.dev/documentation/text_indexing/latest/text_indexing/TextIndexer/indexJson.html) indexes the fields in a `JSON` document; and 
* [indexCollection](https://pub.dev/documentation/text_indexing/latest/text_indexing/TextIndexer/indexCollection.html) indexes the fields of all the documents in a JSON document collection.

Use the unnamed factory constructor to instantiate a [TextIndexer](https://pub.dev/documentation/text_indexing/latest/text_indexing/TextIndexer-class.html) with the index of your choice, or extend [TextIndexerBase](https://pub.dev/documentation/text_indexing/latest/text_indexing/TextIndexerBase-class.html).

(*[back to top](#)*)

## Definitions

The following definitions are used throughout the [documentation](https://pub.dev/documentation/text_analysis/latest/):

* `corpus`- the collection of `documents` for which an `index` is maintained.
* `cosine similarity` - similarity of two vectors measured as the cosine of the angle between them, that is, the dot product of the vectors divided by the product of their euclidian lengths (from [Wikipedia](https://en.wikipedia.org/wiki/Cosine_similarity)).
* `character filter` - filters characters from text in preparation of tokenization .  
* `Damerau–Levenshtein distance` - a metric for measuring the `edit distance` between two `terms` by counting the minimum number of operations (insertions, deletions or substitutions of a single character, or transposition of two adjacent characters) required to change one `term` into the other (from [Wikipedia](https://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance)).
* `dictionary (in an index)` - a hash of `terms` (`vocabulary`) to the frequency of occurence in the `corpus` documents.
* `document` - a record in the `corpus`, that has a unique identifier (`docId`) in the `corpus`'s primary key and that contains one or more text fields that are indexed.
* `document frequency (dFt)` - the number of documents in the `corpus` that contain a term.
* `edit distance` - a measure of how dissimilar two terms are by counting the minimum number of operations required to transform one string into the other (from [Wikipedia](https://en.wikipedia.org/wiki/Edit_distance)).
* `etymology` - the study of the history of the form of words and, by extension, the origin and evolution of their semantic meaning across time (from [Wikipedia](https://en.wikipedia.org/wiki/Etymology)).
* `Flesch reading ease score` - a readibility measure calculated from  sentence length and word length on a 100-point scale. The higher the score, the easier it is to understand the document (from [Wikipedia](https://en.wikipedia.org/wiki/Flesch%E2%80%93Kincaid_readability_tests)).
* `Flesch-Kincaid grade level` - a readibility measure relative to U.S. school grade level.  It is also calculated from sentence length and word length (from [Wikipedia](https://en.wikipedia.org/wiki/Flesch%E2%80%93Kincaid_readability_tests)).
* `IETF language tag` - a standardized code or tag that is used to identify human languages in the Internet. (from [Wikepedia](https://en.wikipedia.org/wiki/IETF_language_tag)).
* `index` - an [inverted index](https://en.wikipedia.org/wiki/Inverted_index) used to look up `document` references from the `corpus` against a `vocabulary` of `terms`. 
* `index-elimination` - selecting a subset of the entries in an index where the `term` is in the collection of `terms` in a search phrase.
* `inverse document frequency (iDft)` - a normalized measure of how rare a `term` is in the corpus. It is defined as `log (N / dft)`, where N is the total number of terms in the index. The `iDft` of a rare term is high, whereas the `iDft` of a frequent term is likely to be low.
* `Jaccard index` measures similarity between finite sample sets, and is defined as the size of the intersection divided by the size of the union of the sample sets (from [Wikipedia](https://en.wikipedia.org/wiki/Jaccard_index)).
* `Map<String, dynamic>` is an acronym for `"Java Script Object Notation"`, a common format for persisting data.
* `k-gram` - a sequence of (any) k consecutive characters from a `term`. A `k-gram` can start with "$", denoting the start of the term, and end with "$", denoting the end of the term. The 3-grams for "castle" are { $ca, cas, ast, stl, tle, le$ }.
* `lemma  or lemmatizer` - lemmatisation (or lemmatization) in linguistics is the process of grouping together the inflected forms of a word so they can be analysed as a single item, identified by the word's lemma, or dictionary form (from [Wikipedia](https://en.wikipedia.org/wiki/Lemmatisation)).
* `n-gram` (sometimes also called Q-gram) is a contiguous sequence of `n` items from a given sample of text or speech. The items can be phonemes, syllables, letters, words or base pairs according to the application. The `n-grams` typically are collected from a text or speech `corpus`. When the items are words, `n-grams` may also be called shingles (from [Wikipedia](https://en.wikipedia.org/wiki/N-gram)).
* `Natural language processing (NLP)` is a subfield of linguistics, computer science, and artificial intelligence concerned with the interactions between computers and human language, in particular how to program computers to process and analyze large amounts of natural language data (from [Wikipedia](https://en.wikipedia.org/wiki/Natural_language_processing)).
* `Part-of-Speech (PoS) tagging` is the task of labelling every word in a sequence of words with a tag indicating what lexical syntactic category it assumes in the given sequence (from [Wikipedia](https://en.wikipedia.org/wiki/Part-of-speech_tagging)).
* `Phonetic transcription` - the visual representation of speech sounds (or phones) by means of symbols. The most common type of phonetic transcription uses a phonetic alphabet, such as the International Phonetic Alphabet (from [Wikipedia](https://en.wikipedia.org/wiki/Phonetic_transcription)).
* `postings` - a separate index that records which `documents` the `vocabulary` occurs in.  In a positional `index`, the postings also records the positions of each `term` in the `text` to create a positional inverted `index`.
* `postings list` - a record of the positions of a `term` in a `document`. A position of a `term` refers to the index of the `term` in an array that contains all the `terms` in the `text`. In a zoned `index`, the `postings lists` records the positions of each `term` in the `text` a `zone`.
* `stem or stemmer` -  stemming is the process of reducing inflected (or sometimes derived) words to their word stem, base or root form (generally a written word form) (from [Wikipedia](https://en.wikipedia.org/wiki/Stemming)).
* `stopwords` - common words in a language that are excluded from indexing.
* `term` - a word or phrase that is indexed from the `corpus`. The `term` may differ from the actual word used in the corpus depending on the `tokenizer` used.
* `term filter` - filters unwanted terms from a collection of terms (e.g. stopwords), breaks compound terms into separate terms and / or manipulates terms by invoking a `stemmer` and / or `lemmatizer`.
* `term expansion` - finding terms with similar spelling (e.g. spelling correction) or synonyms for a term. 
* `term frequency (Ft)` - the frequency of a `term` in an index or indexed object.
* `term position` - the zero-based index of a `term` in an ordered array of `terms` tokenized from the `corpus`.
* `text` - the indexable content of a `document`.
* `token` - representation of a `term` in a text source returned by a `tokenizer`. The token may include information about the `term` such as its position(s) (`term position`) in the text or frequency of occurrence (`term frequency`).
* `token filter` - returns a subset of `tokens` from the tokenizer output.
* `tokenizer` - a function that returns a collection of `token`s from `text`, after applying a character filter, `term` filter, [stemmer](https://en.wikipedia.org/wiki/Stemming) and / or [lemmatizer](https://en.wikipedia.org/wiki/Lemmatisation).
* `vocabulary` - the collection of `terms` indexed from the `corpus`.
* `zone` - the field or zone of a document that a term occurs in, used for parametric indexes or where scoring and ranking of search results attribute a higher score to documents that contain a term in a specific zone (e.g. the title rather that the body of a document).

(*[back to top](#)*)

## References

* [Manning, Raghavan and Schütze, "*Introduction to Information Retrieval*", Cambridge University Press, 2008](https://nlp.stanford.edu/IR-book/pdf/irbookprint.pdf)
* [University of Cambridge, 2016 "*Information Retrieval*", course notes, Dr Ronan Cummins, 2016](https://www.cl.cam.ac.uk/teaching/1516/InfoRtrv/)
* [Wikipedia (1), "*Inverted Index*", from Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Inverted_index)
* [Wikipedia (2), "*Lemmatisation*", from Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Lemmatisation)
* [Wikipedia (3), "*Stemming*", from Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Stemming)
* [Wikipedia (4), "*Synonym*", from Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Synonym)
* [Wikipedia (5), "*Jaccard Index*", from Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Jaccard_index)
* [Wikipedia (6), "*Flesch–Kincaid readability tests*", from Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Flesch%E2%80%93Kincaid_readability_tests)
* [Wikipedia (7), "*Edit distance*", from Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Edit_distance)
* [Wikipedia (8), "*Damerau–Levenshtein distance*", from Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance)
* [Wikipedia (9), "*Natural language processing*", from Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Natural_language_processing)
* [Wikipedia (10), "*IETF language tag*", from Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/IETF_language_tag)
* [Wikipedia (11), "*Phonetic transcription*", from Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Phonetic_transcription)
* [Wikipedia (12), "*Etymology*", from Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Etymology)
* [Wikipedia (13), "*Part-of-speech tagging*", from Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Part-of-speech_tagging)
* [Wikipedia (14), "*N-gram*", from Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/N-gram)
* [Wikipedia (15), "*Cosine similarity*", from Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Cosine_similarity)

(*[back to top](#)*)
## Issues

If you find a bug please fill an [issue](https://github.com/GM-Consult-Pty-Ltd/text_indexing/issues).  

This project is a supporting package for a revenue project that has priority call on resources, so please be patient if we don't respond immediately to issues or pull requests.

(*[back to top](#)*)




