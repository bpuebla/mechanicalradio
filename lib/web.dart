import 'package:web_scraper/web_scraper.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

export 'web.dart';

void bbcnews(number) async {
  var articles_links = [];
  final webScraper = WebScraper('https://www.bbc.com');

  //if (await webScraper.loadWebPage('/news/world')) {
  //List<Map<String, dynamic>> elements = webScraper.getElement('a', ['href']);
  //List<String> elements = webScraper.getElementTitle('a');
  //var elements2 = elements.skip(209).toList();
  //print(elements2);
  //}
  var response =
      await http.Client().get(Uri.parse("https://www.bbc.com/news/world"));
  if (response.statusCode == 200) {
    var document = parse(response.body);
    var articles = document.getElementsByClassName(
        "gs-c-promo-heading gs-o-faux-block-link__overlay-link gel-pica-bold nw-o-link-split__anchor");
    //print(articles_links);
    for (var i = 0; i < articles.length; i++) {
      articles_links.add(articles[i].attributes["href"]);
    }
    //print(articles[0].attributes["href"]);
    //print(articles_links);
  } else {
    throw Exception('error1');
  }

  var link = "https://www.bbc.com" + articles_links[number];
  print(link);
  response = await http.Client().get(Uri.parse(link));
  if (response.statusCode == 200) {
    var document = parse(response.body);
    var title = document.getElementsByTagName('h1');
    var paragraphs = document.getElementsByTagName('p');
    paragraphs.insert(0, title[0]);
    for (var i = 0; i <= 4; i++) {
      print(paragraphs[i].text);
    }
  } else {
    throw Exception('error2');
  }
  print('s');
}

void main() async {
  var query = "vienna";
  var response = await http.Client().get(Uri.parse(
      "https://www.accuweather.com/en/search-locations?query=" + query));
  var city_result;
  if (response.statusCode == 200) {
    var document = parse(response.body);
    var results =
        document.getElementsByClassName("locations-list content-module");
    city_result = results[0].children[0].attributes['href'];
  } else {
    throw Exception('Wrong query');
  }
  var forecast_now_addr = "https://www.accuweather.com" +
      city_result.replaceAll("weather-forecast", "current-weather");
  var forecast_today_addr = "https://www.accuweather.com" +
      city_result.replaceAll("weather-forecast", "daily-weather-forecast") +
      "?day=1";
  response = await http.Client().get(Uri.parse(forecast_now_addr));
  if (response.statusCode == 200) {
    var document = parse(response.body);
    var curr_forecast =
        document.getElementsByClassName("forecast-container")[0];
    var curr_status = document.getElementsByClassName("phrase")[0].text;
    curr_status = curr_status.substring(0, curr_status.length - 5);
    var curr_temp = curr_forecast
        .getElementsByClassName("temperature")[0]
        .text
        .toLowerCase();

    print(
        "The current weather status is ${curr_status}, with a temperature of ${curr_temp} degrees");
  }
}
