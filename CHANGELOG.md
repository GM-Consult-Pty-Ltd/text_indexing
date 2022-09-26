<!-- 
BSD 3-Clause License
Copyright (c) 2022, GM Consult Pty Ltd
All rights reserved. 
-->

*THIS PACKAGE IS **PRE-RELEASE**, IN ACTIVE DEVELOPMENT AND SUBJECT TO DAILY BREAKING CHANGES.*

### 0.14.5

Upgraded dependencies.

### 0.14.4

Upgraded dependencies.

### 0.14.3+1

Updated documentation.

### 0.14.3

Updated dependencies, tests, examples and documentation.

### 0.14.2

Updated dependencies, tests, examples and documentation.

### 0.14.1+1

Updated documentation.

### 0.14.1

#### New: 
- Added extension property `KGramIndex.terms`.

Updated documentation.

### 0.14.0+1

Updated documentation.

### 0.14.0

#### Breaking Changes:
- Removed class `TextSource`.
- Removed class `Sentence`.
- Removed class `TermPair`.
- Removed `TextAnalyzerConfiguration.sentenceSplitter` from `TextAnalyzerConfiguration` interface.
- Changed `TextTokenizer.tokenize` return value to `List<Token>`.
- Changed `TextTokenizer.tokenizeJson` return value to `List<Token>`.

- Re-structured codebase.
- Updated dependencies, tests, examples and documentation.

### 0.13.0+3

Updated documentation.

### 0.13.0+2

Updated documentation.

### 0.13.0+1

Updated documentation.

### 0.13.0 
**BREAKING CHANGES**

#### Breaking changes:
- Removed `TextIndexer.async`, `TextIndexer.index`  and `TextIndexer.inMemory` factory constructors.
- Added a new unnamed factory constructor for `TextIndexer`.

- Re-structured codebase.
- Updated dependencies, tests, examples and documentation.

### 0.12.0+1

Updated dependencies and documentation.

### 0.12.0
**BREAKING CHANGES**

#### Breaking changes:
- Added method `InvertedIndex.getKGramIndex` to `InvertedIndex` interface.
- Added method `InvertedIndex.upsertKGramIndex` to `InvertedIndex` interface.
- Added field `InvertedIndex.k` to `InvertedIndex` interface.
- Removed field `TextIndexer.postingsStream`.
- Renamed method `TextIndexer.emit` to `TextIndexer.updateIndexes`.
- Added `AsyncIndex.k`, `AsyncIndex.kGramIndexLoader` and `AsyncIndex.kGramIndexUpdater` final fields and parameters to `AsyncIndex` class.
- Added `InMemoryIndex.k`, and `InMemoryIndex.kGramIndex` final fields and parameters to `InMemoryIndex` class.

#### New:
- Type alias `KGramIndex`.
- Type alias `KGramIndexLoader`.
- Type alias `KGramIndexUpdater`.
- Extension method `void KGramIndex.addTermKGrams(Term term, Iterable<KGram> kGrams)`.

Updated dependencies, tests, examples and documentation.

### 0.11.0

#### New:
- Mixin class `AsyncCallbackIndexMixin`. 
- Mixin class `InMemoryIndexMixin`. 

Updated dependencies, tests, examples and documentation.

### 0.10.0

#### Breaking changes:

- `TextIndexerBase` default generative constructor is no longer marked `const` as it has a method body that initializes listeners to `TextIndexer.documentStream` and `TextIndexer.collectionStream`.

#### New:
- Input stream fields `TextIndexer.documentStream` and `TextIndexer.collectionStream` added to `TextIndexer` interface.- 
- Optional named parameter `Stream<Map<String, Map<String, dynamic>>>? collectionStream` added to added to `TextIndexer.async`, `TextIndexer.inMemory` and `TextIndexer.index` factory contructors.

Updated dependencies, tests, examples and documentation.

### 0.9.0

#### Breaking changes:

- Renamed `InvertedPositionalZoneIndex` interface to `InvertedIndex`.
- Renamed `TextIndexer.instance` factory to `TextIndexer.index`.
- Parameter `dictionaryLengthLoader` added to `AsynCallbackIndex` constructor;
- Parameter `dictionaryLengthLoader` added to `AsyncIndexer` constructor;
- Parameter `dictionaryLengthLoader` added to `TextIndexer.async` factory constructor;
- Removed class `InMemoryIndexer`, use factory constructor `TextIndexer.inMemory` in stead.
- Removed class `AsyncIndexer`, use factory constructor `TextIndexer.async` in stead.

#### New:

- Type definition `FtdPostings`.
- Type definition `IdFtIndex`.
- Type definition `IdFt`.
- Type definition `ZoneWeightMap`.
- Field getter `Future<int> InvertedIndex.vocabularyLength`.
- Field getter `Future<int> Function() AsynCallbackIndex.dictionaryLengthLoader`;
- Field getter `int InvertedIndex.phraseLength`.
- Field getter `ZoneWeightMap InvertedIndex.zones`.
- Optional named parameter `ZoneWeightMap zones` added to `TextIndexer.async` factory.
- Optional named parameter `ZoneWeightMap zones` added to `TextIndexer.inMemory` factory.
- Method `Future<FtdPostings> InvertedIndex.getFtdPostings(Iterable<Term>, int)`.
- Method `Future<IdFtIndex> InvertedIndex.getIdFtIndex(Iterable<Term>)`.
- Method `Future<Dictionary> InvertedIndex.getTfIndex(Iterable<Term>)`.

Updated dependencies, tests, examples and documentation.

### 0.8.0+1

Updated dependencies

### 0.8.0
**BREAKING CHANGES**

#### Breaking changes:

- Implementation of `TextIndexer.indexText` changed to also insert postings for every pair of terms in the source text.

Updated dependencies, tests, examples and documentation.

### 0.7.2+1

Updated dependencies

### 0.7.2

Updated dependencies

### 0.7.1

Updated dependencies

### 0.7.0
**BREAKING CHANGES**

#### Breaking changes:
- Renamed `Postings.documents` extension method to `Postings.docIds`.

#### New:
- Extension method `Set<DocId> containsAll(Iterable<Term>)`
- Extension method `Set<DocId> containsAny(Iterable<Term>)`

Updated dependencies, tests, examples and documentation.

### 0.6.0
**BREAKING CHANGES**

#### Breaking changes:

- Changed signature of extension method `Postings.termPostingsList(Term)` to `Postings.termPostingsList([Iterable<Term>?])`.
- Removed field `InMemoryIndexer.dictionary`. Use `InMemoryIndexer.index.dictionary` instead.
- Removed field `InMemoryIndexer.postings`. Use `InMemoryIndexer.index.postings` instead.
- Removed method `TextIndexer.upsertDictionary`. Use `TextIndexer.index.upsertDictionary` instead;
- Removed method `TextIndexer.getDictionary`. Use `TextIndexer.index.getDictionary` instead;
- Removed method `TextIndexer.getPostings`. Use `TextIndexer.index.getPostings` instead;
- Removed method `TextIndexer.upsertPostings`. Use `TextIndexer.index.upsertPostings` instead.
- Removed field `InMemoryIndexer.dictionary`. Use `index.dictionary` instead.
- Removed field `InMemoryIndexer.postings`. Use `index.postings` instead.
- Added new field `InvertedIndex.analyzer`, changing the signatures of factory constructors `TextIndexer.inMemory` and 'TextIndexer.async'.

Updated dependencies, tests, examples and documentation.

### 0.6.0-2
**BREAKING CHANGES**

#### Breaking changes:

- Changed signature of extension method `Postings.termPostingsList(Term)` to `Postings.termPostingsList([Iterable<Term>?])`.

Updated dependencies, tests, examples and documentation.

### 0.6.0-1
**BREAKING CHANGES**

Updated dependencies, tests, examples and documentation.

### 0.5.0
**BREAKING CHANGES**

#### Deprecated:

- Field `InMemoryIndexer.dictionary` is deprecated. Use `index.dictionary` instead.
- Field `InMemoryIndexer.postings` is deprecated. Use `index.postings` instead.

Updated dependencies, tests, examples and documentation.

### 0.4.0
**BREAKING CHANGES**

#### Breaking changes:

- Renamed method `TextIndexer.index` to `TextIndexer.indexText`.
- Renamed class `PersistedIndexer` to `AsyncIndexer`.

#### New:

- `InvertedIndex` interface and implementation.
- `TextIndexer.index` field getter.
- `TextIndexer.index` factory constructor.
- `TextIndexer.async` factory constructor.
- `TextIndexer.inMemory` factory constructor.

#### Deprecated:

- Method `TextIndexer.upsertDictionary` is deprecated. Use `TextIndexer.index.upsertDictionary` instead;
- Method `TextIndexer.getDictionary` is deprecated. Use `TextIndexer.index.getDictionary` instead;
- Method `TextIndexer.getPostings` is deprecated. Use `TextIndexer.index.getPostings` instead;
- Method `TextIndexer.upsertPostings` is deprecated. Use `TextIndexer.index.upsertPostings` instead.
- Field `InMemoryIndexer.dictionary` is deprecated. Use `index.dictionary` instead.
- Field `InMemoryIndexer.postings` is deprecated. Use `index.postings` instead.

Updated dependencies, tests, examples and documentation.

### 0.3.2

#### New:

- `JSON` and `JsonCollection` type aliases.
- `TextIndexer.indexCollection` method.
- `PostingsExtension.documents` getter.

Updated dependencies, tests, examples and documentation.

### 0.3.1

#### New:

- `JSON` and `JsonCollection` type aliases.
- implemented `TextIndexer.indexCollection` method.

Updated dependencies, tests, examples and documentation.

### 0.3.0
**BREAKING CHANGES**

#### Breaking changes:
- Removed interface `Document`.

### 0.2.0
**BREAKING CHANGES**

#### New:

- `ZonePostings`, `DocumentPostings`, and `FieldPostingsEntry`  type definitions.
- `Ft`, `Pt`, `TermPositions` and `DocId` type aliases.
- interface `Document`.

#### Breaking changes:

- Replaced object-model class `PostingsEntry` with typedef `PostingsEntry`.
- Replaced object-model class `DocumentPostingsEntry` with typedef `DocumentPostingsEntry`.
- Replaced object-model class `DictionaryEntry` with typedef `DictionaryEntry`.

Restructured and simplified the codebase.

Updated dependencies, tests, examples and documentation.

### 0.1.0

#### New:

- `ITextIndexer.indexJson` method.

Updated dependencies, tests, examples and documentation.

### 0.0.2+1

Updated dependencies, tests, examples and documentation.

### 0.0.2

#### New:

- `text_analysis` package to exports.

Updated dependencies, tests, examples and documentation.

### 0.0.1+10

Updated dependencies, tests, examples and documentation.

### 0.0.1+9

Updated dependencies, tests, examples and documentation.

### 0.0.1+8

Updated dependencies, tests, examples and documentation.

### 0.0.1+7

Updated dependencies, tests, examples and documentation.

### 0.0.1+6

Re-worked private methods to suit changes in text_analysis package.

Updated dependencies, tests, examples and documentation.

### 0.0.1+5

- Updated dependencies.

### 0.0.1+4

Updated dependencies, tests, examples and documentation.

### 0.0.1+3

Updated dependencies, tests, examples and documentation.

### 0.0.1+2

Updated documentation.

### 0.0.1+1


Updated dependencies, tests, examples and documentation.

### 0.0.1
**BREAKING CHANGES**

Interfaces finalized (see [breaking changes](#breaking-changes))

#### Breaking changes:

- `TermDictionary` renamed `Dictionary`.
- `DocumentPostingsEntry` renamed `Postings`.
- `PostingsMapEntry` renamed `PostingsEntry`.
- `Term` renamed `DictionaryEntry`.
- `TermPositions` renamed `DocumentPostingsEntry`.
- `AsyncIndexer` implementation.
- `TextIndexerBase` implementation.
- `InMemoryIndexer` implementation.

Updated dependencies, tests, examples and documentation.

### 0.0.1-beta.4

Updated dependencies, tests, examples and documentation.

### 0.0.1-beta.3
**BREAKING CHANGES**

#### New:

- `AsyncIndexer` class.

#### Breaking changes:

- `TextIndexerBase` implementation.
- `InMemoryIndexer` implementation.

Updated dependencies, tests, examples and documentation.

### 0.0.1-beta.2

#### New:

- `TextIndexerBase`.
- `InMemoryIndexer`.

Updated dependencies, tests, examples and documentation.

### 0.0.1-beta.1

Initial version.