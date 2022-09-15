// Copyright ©2022, GM Consult (Pty) Ltd
// BSD 3-Clause License
// All rights reserved

// ignore: unused_import
import 'package:text_indexing/text_indexing.dart';

/// Two examples using the indexers in this package are provided:
/// - [_inMemoryIndexerExample] is a simple example of a [InMemoryIndexer]
///   indexing the [textData] dataset; and
/// - [_persistedIndexerExample] is a simple example of a [PersistedIndexer]
///   indexing the [textData] dataset.
void main() async {
  //

  // Run a simple example of the [InMemoryIndexer] on the [textData] dataset.
  await _inMemoryIndexerExample(textData);

  //  Run a simple example of the [PersistedIndexer] on the [textData] dataset.
  await _persistedIndexerExample(jsonData);

  //
}

/// A simple example of the [InMemoryIndexer] on the [documents] dataset:
/// - initialize the [Dictionary];
/// - initialize the [Postings];
/// - initialize a [InMemoryIndexer];
/// - listen to the [InMemoryIndexer.postingsStream], printing the
///   emitted postings for each indexed document;
/// - iterate through the sample data;
/// - index each document, adding/updating terms in the [Dictionary]
///   and postings in the [Postings] ; and
/// - print the top 5 most popular [Dictionary.terms].
Future<void> _inMemoryIndexerExample(Map<String, String> documents) async {
  //

  // - initialize the [Dictionary]
  final dictionary = <String, int>{};

  // - initialize the [Postings]
  final postings = <String, Map<String, Map<String, List<int>>>>{};

  // - initialize a [InMemoryIndexer]
  final indexer = InMemoryIndexer(dictionary: dictionary, postings: postings);

  indexer.postingsStream.listen((event) {
    if (event.isNotEmpty) {
      final PostingsEntry posting = event.entries.first;
      if (posting.value.isNotEmpty) {
        final DocumentPostingsEntry docPostings = posting.value.entries.first;
        final docId = docPostings.docId;
        final terms = event.terms;
        print('$docId: $terms');
      }
    }
  });

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

/// A simple test of the [PersistedIndexer] on a small JSON dataset using a
/// simulated persisted index repository with 50 millisecond latency on
/// read/write operations to [Dictionary] and [Postings] hashmaps:
/// - initialize the [_TestIndex()];
/// - initialize a [PersistedIndexer];
/// - listen to the [PersistedIndexer.postingsStream], printing the
///   emitted postings for each indexed document;
/// - iterate through the JSON documents;
/// - index each document, adding/updating terms in the [_TestIndex.dictionary]
///   and postings in the [_TestIndex.postings] ; and
/// - print the top 5 most popular [_TestIndex.dictionary.terms].
Future<void> _persistedIndexerExample(
    Map<String, Map<String, dynamic>> documents) async {
  //

  // - initialize a [_TestIndex()]
  final index = _TestIndex();

  // - initialize a [InMemoryIndexer]
  final indexer = PersistedIndexer(
      termsLoader: index.loadTerms,
      dictionaryUpdater: index.updateDictionary,
      postingsLoader: index.loadTermPostings,
      postingsUpdater: index.upsertTermPostings);

  indexer.postingsStream.listen((event) {
    if (event.isNotEmpty) {
      final PostingsEntry posting = event.entries.first;
      if (posting.value.isNotEmpty) {
        final DocumentPostingsEntry docPostings = posting.value.entries.first;
        final docId = docPostings.docId;
        final terms = event.terms;
        print('$docId: $terms');
      }
    }
  });

  final fields = ['name', 'description', 'hashTags', 'publicationDate'];
  // - iterate through the sample data
  await Future.forEach(documents.entries,
      (MapEntry<String, Map<String, dynamic>> entry) async {
    // - index each document
    final docId = entry.key;
    final json = entry.value;
    await indexer.indexJson(docId, json, fields);
  });

  // wait for stream elements to complete printing
  await Future.delayed(const Duration(milliseconds: 250));

  // print the 5 most popuplar terms with their frequencies
  var terms = index.dictionary.toList(TermSortStrategy.byFrequency);
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

/// JSON data used to demonstrate persisted indexing of fields in JSON documents.
final jsonData = {
  'ee1760a1-a259-50dc-b11d-8baf34d7d1c5': {
    'avatarImageUrl':
        'https://firebasestorage.googleapis.com/v0/b/buysellhold-322d1.appspot.com/o/logos%2FTSLA%3AXNGS.png?alt=media&token=c365db47-9482-4237-9267-82f72854d161',
    'description':
        'A 20-for-1 stock split gave a nice short-term boost to Amazon (AMZN) - Get Amazon.com Inc. Report in late May and in early June, while Alphabet (GOOGL) - Get Alphabet Inc. Report (GOOG) - Get Alphabet Inc. Report has a planned 20-for-1 stock split for next month. Tesla  (TSLA) - Get Tesla Inc. Report is also waiting on shareholder approval for a 3-for-1 stock split. ',
    'entityType': 'NewsItem',
    'hashTags': ['#Tesla'],
    'id': 'ee1760a1-a259-50dc-b11d-8baf34d7d1c5',
    'itemGuid':
        'trading-shopify-stock-ahead-of-10-for-1-stock-split-technical-analysis-june-2022?puc=yahoo&cm_ven=YAHOO&yptr=yahoo',
    'linkUrl':
        'https://www.thestreet.com/investing/trading-shopify-stock-ahead-of-10-for-1-stock-split-technical-analysis-june-2022?puc=yahoo&cm_ven=YAHOO&yptr=yahoo',
    'locale': 'Locale.en_US',
    'name': 'Shopify Stock Split What the Charts Say Ahead of 10-for-1 Split',
    'publicationDate': '2022-06-28T17:44:00.000Z',
    'publisher': {
      'linkUrl': 'http://www.thestreet.com/',
      'title': 'TheStreet com'
    },
    'timestamp': 1656464362162
  },
  'ee1d9610-b902-53e6-8264-840bd403365b': {
    'avatarImageUrl':
        'https://firebasestorage.googleapis.com/v0/b/buysellhold-322d1.appspot.com/o/logos%2FO%3AXNYS.png?alt=media&token=15b5e8fe-bec2-4711-b0f7-e5a631287e9e',
    'description': 'OR',
    'entityType': 'NewsItem',
    'hashTags': ['#RealtyIncome'],
    'id': 'ee1d9610-b902-53e6-8264-840bd403365b',
    'itemGuid': 'auddev&yptr=yahoo',
    'linkUrl':
        'https://www.ft.com/cms/s/0ea7bcc1-d3a6-4897-8da3-98798c3be487,s01=1.html?ftcamp=traffic/partner/feed_headline/us_yahoo/auddev&yptr=yahoo',
    'locale': 'Locale.en_US',
    'name': 'History says US stock market has further to fall',
    'publicationDate': '2022-06-25T12:35:45.000Z',
    'publisher': {'linkUrl': 'http://ft.com/', 'title': 'Financial Times'},
    'timestamp': 1656193158270
  },
  'ef3b0cb6-0297-502b-bd77-283246bc0014': {
    'avatarImageUrl':
        'https://firebasestorage.googleapis.com/v0/b/buysellhold-322d1.appspot.com/o/logos%2FJPM-C%3AXNYS.png?alt=media&token=deba8c6d-019e-4d49-9faa-d641a3cf1986',
    'description':
        'JPMorgan Sees ‘Stratospheric’ \$380 Oil on Worst-Case Russian Cut',
    'entityType': 'NewsItem',
    'hashTags': ['#JPMorganChase'],
    'id': 'ef3b0cb6-0297-502b-bd77-283246bc0014',
    'itemGuid': 'germany-risks-cascade-utility-failures-194853753.html',
    'linkUrl':
        'https://finance.yahoo.com/news/germany-risks-cascade-utility-failures-194853753.html',
    'locale': 'Locale.en_US',
    'name': 'Germany Risks a Cascade of Utility Failures Economy Chief Says',
    'publicationDate': '2022-07-02T19:48:53.000Z',
    'publisher': {
      'linkUrl': 'https://www.bloomberg.com/',
      'title': 'Bloomberg'
    },
    'timestamp': 1656802194091
  },
  'f1064cca-bf6d-5689-900b-ecb8769fe30b': {
    'avatarImageUrl':
        'https://firebasestorage.googleapis.com/v0/b/buysellhold-322d1.appspot.com/o/logos%2FINTC%3AXNGS.png?alt=media&token=cfefaa0a-7f06-42f8-a316-954ded1fd703',
    'description':
        'Under CEO Pat Gelsinger, Intel has committed to massively increasing its capital spending investments by tens of billions of dollars. But with a rapidly slowing global economy, repeated product delays, rising competitive threats, and political uncertainty, it might need more help to fund its ambitions. One good place to find it would be Intel (ticker: INTC) generous dividend payout. While the chip maker has paid a consistent dividend for three decades straight, it needs to do whatever it takes to shore up its future—up to and including cutting its dividend. Under CEO Pat Gelsinger, Intel has committed to massively increasing its capital spending investments by tens of billions of dollars.',
    'entityType': 'NewsItem',
    'hashTags': ['#Intel'],
    'id': 'f1064cca-bf6d-5689-900b-ecb8769fe30b',
    'itemGuid':
        'intel-stock-dividend-future-51656450364?siteid=yhoof2&yptr=yahoo',
    'linkUrl':
        'https://www.barrons.com/articles/intel-stock-dividend-future-51656450364?siteid=yhoof2&yptr=yahoo',
    'locale': 'Locale.en_US',
    'name':
        'Intel Should Slash Its Dividend The Chip Maker s Future May Depend on It',
    'publicationDate': '2022-06-29T12:00:00.000Z',
    'publisher': {'linkUrl': 'http://www.barrons.com/', 'title': 'Barrons com'},
    'timestamp': 1656540522708
  },
  'f2fa8eea-6259-5c83-8865-e0b7f80e691d': {
    'avatarImageUrl':
        'https://firebasestorage.googleapis.com/v0/b/buysellhold-322d1.appspot.com/o/logos%2FINTC%3AXNGS.png?alt=media&token=cfefaa0a-7f06-42f8-a316-954ded1fd703',
    'description':
        'Consumers are being hit by the run-up in gasoline, diesel and other oil products, Mike Muller, head of Asia at Vitol Group, said Sunday on a podcast produced by Dubai-based Gulf Intelligence.',
    'hashTags': ['#Intel', '#JPMorganChase'],
    'id': 'f2fa8eea-6259-5c83-8865-e0b7f80e691d',
    'itemGuid': 'surging-fuel-costs-causing-demand-100930872.html',
    'linkUrl':
        'https://finance.yahoo.com/news/surging-fuel-costs-causing-demand-100930872.html',
    'locale': 'Locale.en_US',
    'name': 'Surging Fuel Costs Are Causing Demand Destruction Says Vitol',
    'publicationDate': '2022-07-03T10:09:30.000Z',
    'publisher': {
      'linkUrl': 'https://www.bloomberg.com/',
      'title': 'Bloomberg'
    },
    'timestamp': 1656881075901
  },
  'f6ee5edf-094f-5892-9b37-71b8f2e90d03': {
    'avatarImageUrl':
        'https://firebasestorage.googleapis.com/v0/b/buysellhold-322d1.appspot.com/o/logos%2FAAPL%3AXNGS.png?alt=media&token=fb44cde6-4552-42e7-b1b0-7eddc92b1dfc',
    'description':
        'The Dow Jones Industrial Average rallied out of the red after the latest Fed minutes were released. EV stock Rivian (RIVN) soared on guidance even as Tesla (TSLA) fell. Microsoft (MSFT) and Apple (AAPL) were among the top blue chips.',
    'entityType': 'NewsItem',
    'hashTags': ['#Apple', '#Tesla'],
    'id': 'f6ee5edf-094f-5892-9b37-71b8f2e90d03',
    'itemGuid': '?src=A00220&yptr=yahoo',
    'linkUrl':
        'https://www.investors.com/market-trend/stock-market-today/dow-jones-rallies-as-fed-minutes-reveal-this-jerome-powell-ev-stock-explodes-on-guidance-tesla-stock-apple-stock-pops/?src=A00220&yptr=yahoo',
    'locale': 'Locale.en_US',
    'name':
        'Dow Jones Rallies As Fed Minutes Reveal This EV Stock Explodes On Guidance Apple Stock Vaults',
    'publicationDate': '2022-07-06T19:15:45.000Z',
    'publisher': {
      'linkUrl': 'http://www.investors.com/',
      'title': "Investor's Business Daily"
    },
    'timestamp': 1657158311943
  },
  'f83c0c39-8cc3-5b0e-91de-61e829ea65dc': {
    'avatarImageUrl':
        'https://firebasestorage.googleapis.com/v0/b/buysellhold-322d1.appspot.com/o/logos%2FXOM%3AXNYS.png?alt=media&token=c94499b0-5937-47ea-8f89-94d65d3ed065',
    'description':
        'Sell Exxon Mobil and other energy stocks before these headwinds hit prices once again: ',
    'entityType': 'NewsItem',
    'hashTags': ['#ExxonMobil'],
    'id': 'f83c0c39-8cc3-5b0e-91de-61e829ea65dc',
    'itemGuid':
        'sell-exxon-mobil-and-other-energy-stocks-before-these-headwinds-once-again-hit-prices-11656527286?siteid=yhoof2&yptr=yahoo',
    'linkUrl':
        'https://www.marketwatch.com/story/sell-exxon-mobil-and-other-energy-stocks-before-these-headwinds-once-again-hit-prices-11656527286?siteid=yhoof2&yptr=yahoo',
    'locale': 'Locale.en_US',
    'name':
        'Sell Exxon Mobil and other energy stocks before these headwinds hit prices once again',
    'publicationDate': '2022-06-29T18:28:00.000Z',
    'publisher': {
      'linkUrl': 'http://www.marketwatch.com/',
      'title': 'MarketWatch'
    },
    'timestamp': 1656630576652
  },
  'fa2b9c9e-096e-5e27-917a-26badeabff83': {
    'avatarImageUrl':
        'https://firebasestorage.googleapis.com/v0/b/buysellhold-322d1.appspot.com/o/logos%2FTSLA%3AXNGS.png?alt=media&token=c365db47-9482-4237-9267-82f72854d161',
    'description':
        'Tesla Pauses Plants After Ending Shaky Quarter With a Production Milestone',
    'entityType': 'NewsItem',
    'hashTags': ['#Tesla'],
    'id': 'fa2b9c9e-096e-5e27-917a-26badeabff83',
    'itemGuid': 'natural-gas-soars-700-becoming-040106114.html',
    'linkUrl':
        'https://finance.yahoo.com/news/natural-gas-soars-700-becoming-040106114.html',
    'locale': 'Locale.en_US',
    'name': 'Natural Gas Soars 700% Becoming Driving Force in the New Cold War',
    'publicationDate': '2022-07-05T04:01:06.000Z',
    'publisher': {
      'linkUrl': 'https://www.bloomberg.com/',
      'title': 'Bloomberg'
    },
    'timestamp': 1657002625523
  }
};

/// A dummy asynchronous term dictionary repository with 50 millisecond latency on
/// read/write operations to the [dictionary] and [postings].
///
/// Use for testing and examples.
class _TestIndex {
  //

  /// The [Dictionary] instance that is the data-store for the index's term
  /// dictionary
  final Dictionary dictionary = {};

  /// The [Dictionary] instance that is the data-store for the index's term
  /// dictionary
  final Postings postings = {};

  /// Implementation of [PostingsLoader].
  ///
  /// Returns a subset of [postings] corresponding to [terms].
  ///
  /// Simulates latency of 50 milliseconds.
  Future<Postings> loadTermPostings(Iterable<String> terms) async {
    final Postings retVal = {};
    for (final term in terms) {
      final entry = postings[term];
      if (entry != null) {
        retVal[term] = entry;
      }
    }
    return retVal;
  }

  /// Implementation of [DictionaryUpdater].
  ///
  /// Adds/overwrites the [values] to [dictionary].
  ///
  /// Simulates latency of 50 milliseconds.
  Future<void> updateDictionary(Dictionary values) async {
    /// Simulate write latency of 50milliseconds.
    await Future.delayed(const Duration(milliseconds: 50));
    dictionary.addAll(values);
  }

  /// Implementation of [PostingsUpdater].
  ///
  /// Adds/overwrites the [values] to [postings].
  ///
  /// Simulates latency of 50 milliseconds.
  Future<void> upsertTermPostings(Postings values) async {
    postings.addAll(values);
  }

  /// Implementation of [DictionaryLoader].
  ///
  /// Returns a subset of [dictionary] corresponding to [terms].
  ///
  /// Simulates latency of 50 milliseconds.
  Future<Dictionary> loadTerms(Iterable<String> terms) async {
    final Dictionary retVal = {};
    for (final term in terms) {
      final entry = dictionary[term];
      if (entry != null) {
        retVal[term] = entry;
      }
    }
    return retVal;
  }
}
