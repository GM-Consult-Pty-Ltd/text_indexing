<!-- 
BSD 3-Clause License
Copyright (c) 2022, GM Consult Pty Ltd
All rights reserved. 
-->

## 1.0.0
**STABLE RELEASE**

## 0.23.0
**BREAKING CHANGES**

### *Breaking changes*
This is a major re-work of the library with a significant simplification of the interfaces:
* Interface `TextTokenizer` removed. Use `TextAnalyzer.tokenize` and `TextAnalyzer.tokenizeJson` in stead.
* Mixin `InvertedIndexMixin` removed.
* Instance method `InvertedIndex.getFtdPostings` removed, use static method `InvertedIndex.ftdPostingsFromPostings` in stead.
* Instance method `InvertedIndex.getIdFtIndex` removed, use static method `InvertedIndex.idFtIndexFromDictionary` in stead.
* Instance method `InvertedIndex.getTfIndex` removed, use static method `InvertedIndex.tfIndexFromPostings` in stead.
* Instance method `InvertedIndex.` removed, use static method `InvertedIndex.` in stead.
* Extension methods `Iterable<DftMapEntry>.sort` and `Iterable<DftMapEntry>.toList` removed.
* Property `InvertedIndex.tokenFilter` removed.
* Class `TextIndexerBase` removed.
* Interface method `TextIndexer.indexDocumentStream` added and implemented in `TextIndexerMixin`.
* Interface method `TextIndexer.indexCollectionStream` added and implemented in `TextIndexerMixin`.
* Factories `TextIndexer`, `TextIndexer.stream` and `TextIndexer.collectionStream` removed.
* Signatures changed of interface methods `TextIndexer.indexText`, `TextIndexer.indexJson` and `TextIndexer.indexCollection`.
* Interface method `TextIndexer.dispose()` added.
* Enum `TermSortStrategy` removed.
* Enum `TokenizingStrategy` removed.
* Interface `TextIndexer` implemented in `InvertedIndex`.
* Changed signature of `TextIndexer.indexText`.
* Changed signature of `TextIndexer.indexDocumentStream`.
* Changed signature of `TextIndexer.indexJson`.
* Changed signature of `TextIndexer.indexCollectionStream`.

### *New*
* Added `InMemoryIndexBase` and `AsyncCallbackIndexBase` to `text_indexing` library exports.

### *Bug fix*
* Fixed keyword postings in indexer.

### *Updated*
* Dependencies.
* Tests.
* Documentation
* Examples.

## 0.23.0-5

### *Bug fix*
* Fixed keyword postings in indexer.

### *Updated*
* Bumped dependency `text_analysis` to ver `0.24.0-5`.

## 0.23.0-4

### *Updated*
* Bumped dependency `text_analysis` to ver `0.24.0-4`.

## 0.23.0-3
**BREAKING CHANGES**

### *Breaking changes*
* Changed signature of `TextIndexer.indexText`.
* Changed signature of `TextIndexer.indexDocumentStream`.
* Changed signature of `TextIndexer.indexJson`.
* Changed signature of `TextIndexer.indexCollectionStream`.

### *Updated*
* Dependencies.
* Tests.
* Documentation
* Examples.

## 0.23.0-2

### *New*
* Added `InMemoryIndexBase` and `AsyncCallbackIndexBase` to `text_indexing` library exports.

### *Updated*
* Dependencies.
* Tests.
* Documentation
* Examples.

## 0.23.0-1
**BREAKING CHANGES**

### *Breaking changes*
This is a major re-work of the library with a significant simplification of the interfaces:
* Interface `TextTokenizer` removed. Use `TextAnalyzer.tokenize` and `TextAnalyzer.tokenizeJson` in stead.
* Mixin `InvertedIndexMixin` removed.
* Instance method `InvertedIndex.getFtdPostings` removed, use static method `InvertedIndex.ftdPostingsFromPostings` in stead.
* Instance method `InvertedIndex.getIdFtIndex` removed, use static method `InvertedIndex.idFtIndexFromDictionary` in stead.
* Instance method `InvertedIndex.getTfIndex` removed, use static method `InvertedIndex.tfIndexFromPostings` in stead.
* Instance method `InvertedIndex.` removed, use static method `InvertedIndex.` in stead.
* Extension methods `Iterable<DftMapEntry>.sort` and `Iterable<DftMapEntry>.toList` removed.
* Property `InvertedIndex.tokenFilter` removed.
* Class `TextIndexerBase` removed.
* Interface method `TextIndexer.indexDocumentStream` added and implemented in `TextIndexerMixin`.
* Interface method `TextIndexer.indexCollectionStream` added and implemented in `TextIndexerMixin`.
* Factories `TextIndexer`, `TextIndexer.stream` and `TextIndexer.collectionStream` removed.
* Signatures changed of interface methods `TextIndexer.indexText`, `TextIndexer.indexJson` and `TextIndexer.indexCollection`.
* Interface method `TextIndexer.dispose()` added.
* Enum `TermSortStrategy` removed.
* Enum `TokenizingStrategy` removed.
* Interface `TextIndexer` implemented in `InvertedIndex`.

### *Updated*
* Dependencies.
* Tests.
* Documentation
* Examples.

## 0.22.4+15

### *Deprecated*
* Interface `TextTokenizer` is deprecated and will be removed from the next stable version of `text_analysis` library. At that time `text_indexer` will be updated to accomodate the change and issued as version 0.23.0.

## 0.22.4+14

### *Updated*
* Bumped dependency `text_analysis` to ver `0.23.7+13`.

## 0.22.4+14

### *Updated*
* Bumped dependency `text_analysis` to ver `0.23.7+13`.

## 0.22.4+13

### *Updated*
* Bumped dependency `text_analysis` to ver `0.23.7+12`.
* Changed `InvertedIndex.nGramRange` to nullable.

## 0.22.4+12

### *Updated*
* Bumped dependency `text_analysis` to ver `0.23.7+11`.
* Changed algo for extension method `JSON.toSourceText`.

## 0.22.4+11

### *Updated*
* Bumped dependency `text_analysis` to ver `0.23.7+10`.

## 0.22.4+10

### *Updated*
* Bumped dependency `text_analysis` to ver `0.23.7+9`.

## 0.22.4+9

### *Updated*
* Bumped dependency `text_analysis` to ver `0.23.7+8`.

## 0.22.4+8

### *Updated*
* Bumped dependency `text_analysis` to ver `0.23.7+7`.

## 0.22.4+7

### *Updated*
* Bumped dependency `text_analysis` to ver `0.23.7+6`.

## 0.22.4+6

### *Updated*
* Bumped dependency `text_analysis` to ver `0.23.7+5`.

## 0.22.4+5

### *Updated*
* Bumped dependency `text_analysis` to ver `0.23.7+4`.

## 0.22.4+4

### *Updated*
* Bumped dependency `text_analysis` to ver `0.23.7+3`.

## 0.22.4+3

### *Updated*
* Bumped dependency `text_analysis` to ver `0.23.7+3`.

## 0.22.4+2

### *Updated*
* Bumped dependency `text_analysis` to ver `0.23.7+2`.

## 0.22.4+1

### *Updated*
* Bumped dependency `text_analysis` to ver `0.23.7+1`.

## 0.22.4

### *Updated*
* Bumped dependency `text_analysis` to ver `0.23.7`.

## 0.22.3

### *Updated*
* Dependency `text_analysis` to ver `0.23.6`.

## 0.22.2

### *Bug fixes*
* Changed `TextIndexer.indexText` to use index strategy.

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.   

### *Updated*
* Dependency `text_analysis` to ver `0.23.5`.

## 0.22.1

### *Updated*
* Dependency `text_analysis` to ver `0.23.2`.

## 0.22.0

### *Breaking changes*
* Added method `InvertedIndex.getCollectionSize`.
* Implemented `InvertedIndex.getCollectionSize`.
* Implemented `AsyncCallbackIndex.getCollectionSize`.
* Renamed function definition `VocabularyLength` to `CollectionSizeCallback`.
* Changed signature of factory `InvertedIndex.inMemory`.
* Changed signature of unnamed factory constructor `InvertedIndex`.

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.   

## 0.21.1

### *New*
* Extension method `double getIdFt(String term, int n)` on `DftMap`.
* Extension method `DftMap getEntries(Iterable<Term> terms)` on `DftMap`.

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.   


## 0.21.0

### *Breaking changes*
* Added field `TokenizingStrategy InvertedIndex.strategy`.
* Added field `InvertedIndex.keywordExtractor`.
* Added method `InvertedIndex.getKeywordPostings`.
* Added method `InvertedIndex.upsertKeywordPostings`.
* Changed signature of method `TextIndexer.updateIndexes`.
* Changed signature of default `InMemoryIndex` constructor.
* Changed signature of default `AsyncCallbackIndex` constructor.
* Changed signature of default `InvertedIndex` factory constructor.
* Changed signature of default `InvertedIndex.inMemory` factory constructor.

### *New*
* Added typedef `KeywordPostingsMap`.
* Added typedef `KeyWordPostings`.
* Added function definition `KeywordPostingsMapLoader`.
* Added function definition `KeywordPostingsMapUpdater`.
* Added base class `InMemoryIndexBase`.
* Implemented field `AsyncCallbackIndex.strategy`.
* Implemented field `InMemoryIndex.strategy`.
* Implemented `InMemoryIndex.getKeywordPostings`.
* Implemented `InMemoryIndex.upsertKeywordPostings`.
* Implemented `InMemoryIndex.keywordExtractor`.
* Implemented `AsyncCallbackIndex.getKeywordPostings`.
* Implemented `AsyncCallbackIndex.upsertKeywordPostings`.
* Implemented `AsyncCallbackIndex.keywordExtractor`.

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.   

## 0.20.0

### *Updated*
* Dependency `text_analysis` to ver `0.21.0`.

## 0.19.0

### *Breaking changes*
* Changed signature of `TextIndexer` default unnamed factory constructor.
* Removed field `TextIndexer.documentStream`.
* Removed field `TextIndexer.collectionStream`.
* Added field `InvertedIndex.nGramRange`.
* Changed the signature of `InvertedIndex` unnamed factory.
* Changed the signature of `InvertedIndex.inMemory` factory.
* Changed the signature of `AsyncCallbackIndex` default constructor.
* Changed the signature of `InMemoryIndex` default constructor.
* Removed field `InvertedIndex.phraseLength`.

### *New*
* Added factory constructor `TextIndexer.collectionStream`.
* Added factory constructor `TextIndexer.stream`.
* Changed `TextIndexer.indexText`

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.   

## 0.18.0

### *Updated*
* Dependency `text_analysis` to ver `0.18.0`.

## 0.17.1

### *Updated*
* Dependency `text_analysis` to ver `0.17.1`.

## 0.17.0+1

### *Updated*
* Dependency `text_analysis` to ver `0.17.0+1`.

## 0.17.0

### *Updated*
* Dependency `text_analysis` to ver` 0.17.0`.

## 0.16.0+3

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.    

## 0.16.0+2

### *Updated*
* Dependencies.

## 0.16.0+1

### *Updated*
* Dependencies.
* License.
* Documentation.

## 0.16.0

### *Breaking changes*
* Default k-gram length changed from k =2 to k = 2 in `AsyncCallbackIndex` and `InMemoryIndex` constructors and 

### *New*
* Unnamed factory constructor `InvertedIndex` returns a [AsyncCallbackIndex] instance.
* Factory constructor `InvertedIndex.inMemory` returns a [InMemoryIndex] instance.

### *Updated*
* Dependencies.
* Tests.
* Documentation.

## 0.15.0+1

### *Updated*
* Dependencies.
* Documentation.

## 0.15.0

### *Breaking changes*
* Renamed the following typedefs:
    - `Dictionary` to `DftMap`;
    - `DictionaryEntry` to `DftMapEntry`;
    - `DictionaryLoader` to `DftMapLoader`;
    - `DictionaryUpdater` to `DftMapUpdater`;
    - `DictionaryLengthLoader` to `VocabularySize`;
    - `KGramIndex` to `KGramsMap`;
    - `KGramIndexLoader` to `KGramsMapLoader`;
    - `KGramIndexUpdater` to `KGramsMapUpdater`;
    - `Postings` to `PostingsMap`;
    - `PostingsEntry` to `PostingsMapEntry`;
    - `PostingsLoader` to `PostingsMapLoader`;
    - `PostingsUpdater` to `PostingsMapUpdater`;
    - `FieldPostingsEntry` to `ZonePostingsMapEntry`;
    - `ZonePostings` to `ZonePostingsMap`;
    - `DocumentPostingsEntry` to `DocPostingsMapEntry`; and
    - `DocumentPostings` to `DocPostingsMap`.  
* Removed `HiveIndex` from the `test` folder.
* Removed `_asyncIndexerExample` from the `example folder.
* Renamed the `text_indexing_extensions` mini-library to `extensions`.
* Renamed the `text_indexing_type_definitions` mini-library to `type_definitions`.

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.    

## 0.14.7

### *New*:
* Added package exports from `text_analysis` to `type_definitions` and `extensions` libraries.

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.14.5+1

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.14.5

### *Updated*
* Dependencies.

## 0.14.4

### *Updated*
* Dependencies.

## 0.14.3+1

### *Updated*
* Documentation.

## 0.14.3

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.14.2

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.14.1+1

### *Updated*
* Documentation.

## 0.14.1

### *New*: 
* Added extension property `KGramIndex.terms`.

### *Updated*
* Documentation.

## 0.14.0+1

### *Updated*
* Documentation.

## 0.14.0

### *Breaking changes*
* Removed class `TextSource`.
* Removed class `Sentence`.
* Removed class `TermPair`.
* Removed `TextAnalyzerConfiguration.sentenceSplitter` from `TextAnalyzerConfiguration` interface.
* Changed `TextTokenizer.tokenize` return value to `List<Token>`.
* Changed `TextTokenizer.tokenizeJson` return value to `List<Token>`.
* Re-structured codebase. \

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.13.0+3

### *Updated*
* Documentation.

## 0.13.0+2

### *Updated*
* Documentation.

## 0.13.0+1

### *Updated*
* Documentation.

## 0.13.0 
**BREAKING CHANGES**

### *Breaking changes*
* Removed `TextIndexer.async`, `TextIndexer.index`  and `TextIndexer.inMemory` factory constructors.
* Added a new unnamed factory constructor for `TextIndexer`.
* Re-structured codebase.
### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.12.0+1

Updated dependencies and documentation.

## 0.12.0
**BREAKING CHANGES**

### *Breaking changes*
* Added method `InvertedIndex.getKGramIndex` to `InvertedIndex` interface.
* Added method `InvertedIndex.upsertKGramIndex` to `InvertedIndex` interface.
* Added field `InvertedIndex.k` to `InvertedIndex` interface.
* Removed field `TextIndexer.postingsStream`.
* Renamed method `TextIndexer.emit` to `TextIndexer.updateIndexes`.
* Added `AsyncIndex.k`, `AsyncIndex.kGramIndexLoader` and `AsyncIndex.kGramIndexUpdater` final fields and parameters to `AsyncIndex` class.
* Added `InMemoryIndex.k`, and `InMemoryIndex.kGramIndex` final fields and parameters to `InMemoryIndex` class.

### *New*:
* Type alias `KGramIndex`.
* Type alias `KGramIndexLoader`.
* Type alias `KGramIndexUpdater`.
* Extension method `void KGramIndex.addTermKGrams(Term term, Iterable<KGram> kGrams)`.

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.11.0

### *New*:
* Mixin class `AsyncCallbackIndexMixin`. 
* Mixin class `InMemoryIndexMixin`. 

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.10.0

### *Breaking changes*
* `TextIndexerBase` default generative constructor is no longer marked `const` as it has a method body that initializes listeners to `TextIndexer.documentStream` and `TextIndexer.collectionStream`.

### *New*:
* Input stream fields `TextIndexer.documentStream` and `TextIndexer.collectionStream` added to `TextIndexer` interface.- 
* Optional named parameter `Stream<Map<String, Map<String, dynamic>>>? collectionStream` added to added to `TextIndexer.async`, `TextIndexer.inMemory` and `TextIndexer.index` factory contructors.

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.9.0

### *Breaking changes*
* Renamed `InvertedPositionalZoneIndex` interface to `InvertedIndex`.
* Renamed `TextIndexer.instance` factory to `TextIndexer.index`.
* Parameter `dictionaryLengthLoader` added to `AsynCallbackIndex` constructor;
* Parameter `dictionaryLengthLoader` added to `AsyncIndexer` constructor;
* Parameter `dictionaryLengthLoader` added to `TextIndexer.async` factory constructor;
* Removed class `InMemoryIndexer`, use factory constructor `TextIndexer.inMemory` in stead.
* Removed class `AsyncIndexer`, use factory constructor `TextIndexer.async` in stead.

### *New*:
* Type definition `FtdPostings`.
* Type definition `IdFtIndex`.
* Type definition `IdFt`.
* Type definition `ZoneWeightMap`.
* Field getter `Future<int> InvertedIndex.vocabularyLength`.
* Field getter `Future<int> Function() AsynCallbackIndex.dictionaryLengthLoader`;
* Field getter `int InvertedIndex.phraseLength`.
* Field getter `ZoneWeightMap InvertedIndex.zones`.
* Optional named parameter `ZoneWeightMap zones` added to `TextIndexer.async` factory.
* Optional named parameter `ZoneWeightMap zones` added to `TextIndexer.inMemory` factory.
* Method `Future<FtdPostings> InvertedIndex.getFtdPostings(Iterable<Term>, int)`.
* Method `Future<IdFtIndex> InvertedIndex.getIdFtIndex(Iterable<Term>)`.
* Method `Future<Dictionary> InvertedIndex.getTfIndex(Iterable<Term>)`.

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.8.0+1

Updated dependencies

## 0.8.0
**BREAKING CHANGES**

### *Breaking changes*
* Implementation of `TextIndexer.indexText` changed to also insert postings for every pair of terms in the source text.

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.7.2+1

Updated dependencies

## 0.7.2

Updated dependencies

## 0.7.1

Updated dependencies

## 0.7.0
**BREAKING CHANGES**

### *Breaking changes*
* Renamed `Postings.documents` extension method to `Postings.docIds`.

### *New*:
* Extension method `Set<DocId> containsAll(Iterable<Term>)`
* Extension method `Set<DocId> containsAny(Iterable<Term>)`

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.6.0
**BREAKING CHANGES**

### *Breaking changes*
* Changed signature of extension method `Postings.termPostingsList(Term)` to `Postings.termPostingsList([Iterable<Term>?])`.
* Removed field `InMemoryIndexer.dictionary`. Use `InMemoryIndexer.index.dictionary` instead.
* Removed field `InMemoryIndexer.postings`. Use `InMemoryIndexer.index.postings` instead.
* Removed method `TextIndexer.upsertDictionary`. Use `TextIndexer.index.upsertDictionary` instead;
* Removed method `TextIndexer.getDictionary`. Use `TextIndexer.index.getDictionary` instead;
* Removed method `TextIndexer.getPostings`. Use `TextIndexer.index.getPostings` instead;
* Removed method `TextIndexer.upsertPostings`. Use `TextIndexer.index.upsertPostings` instead.
* Removed field `InMemoryIndexer.dictionary`. Use `index.dictionary` instead.
* Removed field `InMemoryIndexer.postings`. Use `index.postings` instead.
* Added new field `InvertedIndex.analyzer`, changing the signatures of factory constructors `TextIndexer.inMemory` and 'TextIndexer.async'.

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.6.0-2
**BREAKING CHANGES**

### *Breaking changes*
* Changed signature of extension method `Postings.termPostingsList(Term)` to `Postings.termPostingsList([Iterable<Term>?])`.

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.6.0-1
**BREAKING CHANGES**

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.5.0
**BREAKING CHANGES**

#### Deprecated:
* Field `InMemoryIndexer.dictionary` is deprecated. Use `index.dictionary` instead.
* Field `InMemoryIndexer.postings` is deprecated. Use `index.postings` instead.

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.4.0
**BREAKING CHANGES**

### *Breaking changes*
* Renamed method `TextIndexer.index` to `TextIndexer.indexText`.
* Renamed class `PersistedIndexer` to `AsyncIndexer`.

### *New*:
* `InvertedIndex` interface and implementation.
* `TextIndexer.index` field getter.
* `TextIndexer.index` factory constructor.
* `TextIndexer.async` factory constructor.
* `TextIndexer.inMemory` factory constructor.

#### Deprecated:
* Method `TextIndexer.upsertDictionary` is deprecated. Use `TextIndexer.index.upsertDictionary` instead;
* Method `TextIndexer.getDictionary` is deprecated. Use `TextIndexer.index.getDictionary` instead;
* Method `TextIndexer.getPostings` is deprecated. Use `TextIndexer.index.getPostings` instead;
* Method `TextIndexer.upsertPostings` is deprecated. Use `TextIndexer.index.upsertPostings` instead.
* Field `InMemoryIndexer.dictionary` is deprecated. Use `index.dictionary` instead.
* Field `InMemoryIndexer.postings` is deprecated. Use `index.postings` instead.

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.3.2

### *New*:
* `JSON` and `JsonCollection` type aliases.
* `TextIndexer.indexCollection` method.
* `PostingsExtension.documents` getter.

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.3.1

### *New*:
* `JSON` and `JsonCollection` type aliases.
* implemented `TextIndexer.indexCollection` method.

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.3.0
**BREAKING CHANGES**

### *Breaking changes*
* Removed interface `Document`.

## 0.2.0
**BREAKING CHANGES**

### *New*:
* `ZonePostings`, `DocumentPostings`, and `FieldPostingsEntry`  type definitions.
* `Ft`, `Pt`, `TermPositions` and `DocId` type aliases.
* interface `Document`.

### *Breaking changes*
* Replaced object-model class `PostingsEntry` with typedef `PostingsEntry`.
* Replaced object-model class `DocumentPostingsEntry` with typedef `DocumentPostingsEntry`.
* Replaced object-model class `DictionaryEntry` with typedef `DictionaryEntry`.

Restructured and simplified the codebase.

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.1.0

### *New*:
* `ITextIndexer.indexJson` method.

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.0.2+1

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.0.2

### *New*:
* `text_analysis` package to exports.

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.0.1+10

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.0.1+9

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.0.1+8

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.0.1+7

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.0.1+6

### *New*:
* Re-worked private methods to suit changes in text_analysis package.

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.0.1+5

### *Updated*
* Dependencies.

## 0.0.1+4

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.0.1+3

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.0.1+2

### *Updated*
* Documentation.

## 0.0.1+1


### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.0.1
**BREAKING CHANGES**

Interfaces finalized (see [breaking changes](#breaking-changes))

### *Breaking changes*
* `TermDictionary` renamed `Dictionary`.
* `DocumentPostingsEntry` renamed `Postings`.
* `PostingsMapEntry` renamed `PostingsEntry`.
* `Term` renamed `DictionaryEntry`.
* `TermPositions` renamed `DocumentPostingsEntry`.
* `AsyncIndexer` implementation.
* `TextIndexerBase` implementation.
* `InMemoryIndexer` implementation.

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.0.1-beta.4

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.0.1-beta.3
**BREAKING CHANGES**

### *New*:
* `AsyncIndexer` class.

### *Breaking changes*
* `TextIndexerBase` implementation.
* `InMemoryIndexer` implementation.

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.0.1-beta.2

### *New*:
* `TextIndexerBase`.
* `InMemoryIndexer`.

### *Updated*
* Dependencies.
* Tests.
* Examples.
* Documentation.  

## 0.0.1-beta.1

Initial version.