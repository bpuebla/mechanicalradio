import 'package:html/dom.dart';
import 'package:web_scraper/web_scraper.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

export 'web.dart';

Future<Document> fetchDocument(link) async {
  // get html doc of link
  var response = await http.Client().get(Uri.parse(link));
  if (response.statusCode == 200) {
    var document = await parse(response.body);
    return document;
  } else {
    throw Exception('URL $link not found');
  }
}

// BBC WORLD NEWS
Future<String> bbcnews(number) async {
  var articlesLinks = [];

  var document = await fetchDocument("https://www.bbc.com/news/world");

  var articles = document.getElementsByClassName(
      "gs-c-promo-heading gs-o-faux-block-link__overlay-link gel-pica-bold nw-o-link-split__anchor");
  //print(articles_links);
  for (var i = 0; i < articles.length; i++) {
    articlesLinks.add(articles[i].attributes["href"]);
    var articleLink = "https://www.bbc.com" + articlesLinks[number];
    document = await fetchDocument(articleLink);
    var title = document.getElementsByTagName('h1');
    var paragraphs = document.getElementsByTagName('p');
    paragraphs.insert(0, title[0]);
    for (var i = 0; i <= number; i++) {
      print(paragraphs[i].text);
    }
  }
  return '';
}

// BBC NEWS FIXED

Future<String> bbcnews2(number) async {
  var document = await fetchDocument("https://www.bbc.com/news/world");

  var articles = document.getElementsByTagName("h3");
  articles.removeAt(0); // first one is duplicated
  //print(articles_links);
  var linkEnd = articles[number].parent?.attributes['href'];
  var articleLink = "https://www.bbc.com" + linkEnd!;
  document = await fetchDocument(articleLink);
  var title = document.getElementsByTagName('h1');
  var paragraphs = document.getElementsByTagName('p');
  paragraphs.insert(0, title[0]);
  var information = '';
  for (var i = 0; i <= 3; i++) {
    information += paragraphs[i].text + ' ';
  }
  return information;
}

// Weather parsing
Future<String> weather(city, current) async {
  String? cityResult;
  String forecastNowAddr;
  String forecastTodayAddr;

  var document = await fetchDocument(
      "https://www.accuweather.com/en/search-locations?query=" + city);
  var results =
      document.getElementsByClassName("locations-list content-module");
  cityResult = results[0].children[0].attributes['href'];

  if (cityResult == null) {
    return ('No weather info about' + city);
  }
  //print(forecast_now_addr);
  // get current and daily weather link
  print(cityResult);
  document = await fetchDocument("https://www.accuweather.com" + cityResult);
  print(document.getElementsByClassName(
      "cur-con-weather-card card-module non-ad content-module lbar-panel"));
  var weatherLink = document
      .getElementsByClassName(
          "cur-con-weather-card card-module non-ad content-module lbar-panel")[0]
      .attributes["href"];

  forecastNowAddr = "https://www.accuweather.com" + weatherLink!;

  forecastTodayAddr = "https://www.accuweather.com" +
      weatherLink.replaceAll("current-weather", "daily-weather-forecast") +
      "?day=1";
  print(forecastNowAddr);
  print(forecastTodayAddr);

  document = await fetchDocument(forecastNowAddr);
  if (current == true) {
    var currStatus =
        document.getElementsByClassName("phrase")[0].text.trim().toLowerCase();
    //curr_status = curr_status.substring(0, curr_status.length - 5);
    var currTemp =
        document.getElementsByClassName("temp")[0].text.trim().toLowerCase();
    currTemp = currTemp.substring(0, 2);
    //print(document.body?.innerHtml);
    //var curr_wind = document
    //    .getElementsByClassName("detail-item spaced-content")[3]
    //    .children[1];
    var currHumidity;
    var currWind;

    return ("The current weather status is $currStatus, with a temperature of $currTemp degrees");
  } else {
    var dayStatus =
        document.getElementsByClassName("phrase")[1].text.toLowerCase();
    //curr_status = curr_status.substring(0, curr_status.length - 5);
    var dayTemp = document
        .getElementsByClassName("temperature")[0]
        .text
        .trim()
        .toLowerCase();
    dayTemp = dayTemp.substring(0, 2);
    //print(document.body?.innerHtml);
    //var curr_wind = document
    //    .getElementsByClassName("detail-item spaced-content")[3]
    //    .children[1];
    var dayHumidity;
    var dayWind;

    return ("The prediction for today's weather is $dayStatus, with a temperature of $dayTemp degrees");
  }
}

Future<String> getCurrentWeather(city) async {
  String currentWeather = await weather(city, true);
  return currentWeather;
}

Future<String> getDayWeather(city) async {
  String dayWeather = await weather(city, false);
  return dayWeather;
}

// LOCAL NEWS TITLES
Future<List<Element>> googleNews() async {
  var document = await fetchDocument(
      'https://news.google.com/topics/CAAqHAgKIhZDQklTQ2pvSWJHOWpZV3hmZGpJb0FBUAE?hl=en');
  var titles = document.getElementsByTagName('h3');
  return titles;

  //get actual city news
}

String getLocalNewsTitle(titles, index) {
  if (titles.isEmpty) {
    return ('No local news in your area');
  }
  return titles[index].text;
}

// WIKIPEDIA INFO
Future<String> wikipedia(String spacedQuery) async {
  var query = spacedQuery.replaceAll(' ', '%20');
  print(query);
  var document = await fetchDocument(
      'https://en.wikipedia.org/w/index.php?search=' + query);
  final searchResults = document.getElementsByClassName('mw-search-results');
  if (searchResults.isNotEmpty) {
    final link =
        searchResults[0].getElementsByTagName('href')[0].attributes['href'];
    document = await fetchDocument(link);
  } else if (document
      .getElementsByClassName('mw-search-nonefound')
      .isNotEmpty) {
    //print('none');
    return ('Information about ' + spacedQuery + ' is not available');
  }

  var textParagraphs =
      document.getElementsByClassName('mw-parser-output')[0].children;
  while (textParagraphs[0].localName != 'p' ||
      textParagraphs[0].className == 'mw-empty-elt') {
    textParagraphs.removeAt(0);
    //print('removed');
  }
  var information = textParagraphs[0]
      .text
      .replaceAllMapped(RegExp(r'\[.*?\]'), (match) => '');
  //print(information);
  return (information);
}

void main() async {
  //var lol = await wikipedia('diego maradona');
  //weather('vienna', true);
  var localNews = await googleNews();
  print(getLocalNewsTitle(localNews, 0));
}
