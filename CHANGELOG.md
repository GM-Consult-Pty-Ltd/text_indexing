<!-- 
BSD 3-Clause License
Copyright (c) 2022, GM Consult Pty Ltd
All rights reserved. 
-->

### 0.6.0-1 (PRE-RELEASE, BREAKING CHANGES)

### 0.5.0 (PRE-RELEASE, BREAKING CHANGES)

#### Deprecated:

- Field `InMemoryIndexer.dictionary` is deprecated. Use `index.dictionary` instead.
- Field `InMemoryIndexer.postings` is deprecated. Use `index.postings` instead.

Updated dependencies, tests, examples and documentation.

### 0.4.0 (PRE-RELEASE, BREAKING CHANGES)

#### Breaking changes:

- Renamed method `TextIndexer.index` to `TextIndexer.indexText`.
- Renamed class `PersistedIndexer` to `AsyncIndexer`.

#### New:

- `InvertedPositionalZoneIndex` interface and implementation.
- `TextIndexer.index` field getter.
- `TextIndexer.instance` factory constructor.
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

### 0.3.2 (PRE-RELEASE)

#### New:

- `JSON` and `JsonCollection` type aliases.
- `TextIndexer.indexCollection` method.
- `PostingsExtension.documents` getter.

Updated dependencies, tests, examples and documentation.

### 0.3.1 (PRE-RELEASE)

#### New:

- `JSON` and `JsonCollection` type aliases.
- implemented `TextIndexer.indexCollection` method.

Updated dependencies, tests, examples and documentation.

### 0.3.0 (PRE-RELEASE, BREAKING CHANGES)

#### Breaking changes:
- Removed interface `Document`.

### 0.2.0 (PRE-RELEASE, BREAKING CHANGES)

#### New:

- `FieldPostings`, `DocumentPostings`, and `FieldPostingsEntry`  type definitions.
- `Ft`, `Pt`, `TermPositions` and `DocId` type aliases.
- interface `Document`.

#### Breaking changes:

- Replaced object-model class `PostingsEntry` with typedef `PostingsEntry`.
- Replaced object-model class `DocumentPostingsEntry` with typedef `DocumentPostingsEntry`.
- Replaced object-model class `DictionaryEntry` with typedef `DictionaryEntry`.

Restructured and simplified the codebase.

Updated dependencies, tests, examples and documentation.

### 0.1.0 (PRE-RELEASE)

#### New:

- `ITextIndexer.indexJson` method.

Updated dependencies, tests, examples and documentation.

### 0.0.2+1 (PRE-RELEASE)

Updated dependencies, tests, examples and documentation.

### 0.0.2 (PRE-RELEASE)

#### New:

- `text_analysis` package to exports.

Updated dependencies, tests, examples and documentation.

### 0.0.1+10 (PRE-RELEASE)

Updated dependencies, tests, examples and documentation.

### 0.0.1+9 (PRE-RELEASE)

Updated dependencies, tests, examples and documentation.

### 0.0.1+8 (PRE-RELEASE)

Updated dependencies, tests, examples and documentation.

### 0.0.1+7 (PRE-RELEASE)

Updated dependencies, tests, examples and documentation.

### 0.0.1+6 (PRE-RELEASE)

Re-worked private methods to suit changes in text_analysis package.

Updated dependencies, tests, examples and documentation.

### 0.0.1+5 (PRE-RELEASE)

- Updated dependencies.

### 0.0.1+4 (PRE-RELEASE)

Updated dependencies, tests, examples and documentation.

### 0.0.1+3 (PRE-RELEASE)

Updated dependencies, tests, examples and documentation.

### 0.0.1+2 (PRE-RELEASE)

Updated documentation.

### 0.0.1+1 (PRE-RELEASE)

Updated dependencies, tests, examples and documentation.

### 0.0.1 (PRE-RELEASE, BREAKING CHANGES)

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

### 0.0.1-beta.4 (PRE-RELEASE)

Updated dependencies, tests, examples and documentation.

### 0.0.1-beta.3 (PRE-RELEASE, BREAKING CHANGES)

#### New:

- `AsyncIndexer` class.

#### Breaking changes:

- `TextIndexerBase` implementation.
- `InMemoryIndexer` implementation.

Updated dependencies, tests, examples and documentation.

### 0.0.1-beta.2 (PRE-RELEASE)

#### New:

- `TextIndexerBase`.
- `InMemoryIndexer`.

Updated dependencies, tests, examples and documentation.

### 0.0.1-beta.1 (PRE-RELEASE)

Initial version.