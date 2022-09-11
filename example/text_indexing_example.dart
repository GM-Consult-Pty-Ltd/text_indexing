// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

// ignore: unused_import
import 'package:text_indexing/text_indexing.dart';

/// A simple test of the [InMemoryIndexer] on a small dataset:
/// - initialize the [TermDictionary];
/// - initialize the [PostingsMap];
/// - initialize a [InMemoryIndexer];
/// - listen to the [InMemoryIndexer.postingsStream], printing the
///   emitted postings for each indexed document;
/// - get the sample data from [textData];
/// - iterate through the [textData];
/// - index each document, adding/updating terms in the [TermDictionary]
///   and postings in the [PostingsMap] ; and
/// - print the top 5 most popular [TermDictionary.terms].
void main() async {
  //

  // - initialize the [TermDictionary]
  final dictionary = <String, int>{};

  // - initialize the [PostingsMap]
  final postings = <String, Map<String, List<int>>>{};

  // - initialize a [InMemoryIndexer]
  final indexer = InMemoryIndexer(dictionary: dictionary, postings: postings);

  indexer.postingsStream.listen((event) {
    if (event.isNotEmpty) {
      final docId = event.first.docId;
      final terms = event.map((e) => e.term).toList();
      print('$docId: $terms');
    }
  });

  // - get the sample data
  final documents = textData;

  // - iterate through the sample data
  await Future.forEach(documents.entries, (MapEntry<String, String> doc) async {
    // - index each document
    await indexer.index(doc.key, doc.value);
  });

  // wait for stream elements to complete printing
  await Future.delayed(const Duration(milliseconds: 250));

  // print the 5 most popuplar terms with their frequencies
  var terms = dictionary.toList(TermSortStrategy.byFrequency);
  if (terms.length > 5) {
    terms = terms.sublist(0, 5);
  }
  for (final term in terms) {
    print('${term.term}: ${term.frequency}');
  }
}

/// Four paragraphs of text used for testing.
///
/// Includes numbers, currencies, abbreviations, hyphens and identifiers
final textData = {
  'doc000': 'The Dow Jones rallied even as U.S. troops were put on alert amid '
      'the Ukraine crisis. Tesla stock fought back while Apple '
      'stock struggled. ',
  'doc001': '[TSLA.XNGS] Tesla\'s #TeslaMotor Stock Is Getting Hammered.',
  'doc002': 'Among the best EV stocks to buy and watch, Tesla '
      '(TSLA.XNGS) is pulling back from new highs after a failed breakout '
      'above a \$1,201.05 double-bottom entry. ',
  'doc003': 'Meanwhile, Peloton reportedly finds an activist investor knocking '
      'on its door after a major stock crash fueled by strong indications of '
      'mismanagement. In a scathing new letter released Monday, activist '
      'Tesla Capital is pushing for Peloton to fire CEO, Chairman and '
      'founder John Foley and explore a sale.'
};
