// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

/// Dart library for creating an inverted index on a collection of text documents.
library text_indexing;

export 'src/inverted_index/inverted_index.dart'
    show InvertedIndex, InvertedIndexMixin;
export 'src/inverted_index/in_memory_index.dart'
    show InMemoryIndex, InMemoryIndexMixin;
export 'src/inverted_index/async_index.dart'
    show AsyncCallbackIndex, AsyncCallbackIndexMixin;
export 'src/inverted_index/term_sort_strategy.dart' show TermSortStrategy;
export 'src/text_indexer/text_indexer.dart' show TextIndexer, TextIndexerBase;
export 'package:text_analysis/text_analysis.dart';
