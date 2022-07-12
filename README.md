# mechanicalradio

## Objective

The objective of the project is to develop a working radio that produces endless audio stream consisting on general news, specific news about an inputted keyword and music that fits the theme.

-	Elaborate the mobile app structure with Flutter
-	Implement techniques on web scraping to extract data from news sites, Wikipedia (from keyword) and weather
-	Parsing through the data to obtain readable text.
-	Automatic deduction of a music genre from keyword and from text.
-	Obtainment of a clip from an open music library with the genre
-	Transformation of text to a clip of speech
-	Joining of both clips and presentation on the app

## Documentation
### Widgets
#### App

Stateless widget that builds the Mechanical Radio App as a Material App.
##### Methods
- build(context) : overrides the main build and returns a Material App. On theme it is specified the use of the Roboto font, along with dark background and clear text. Incorporates for everything else (such as app bar) a custom palette with greyblue tones.

#### MyHomepage

Stateful widget that builds the template for the pages.
##### Variables
- news : Contains the news Map from local, world and weather sources, and topic information.
- newsLoaded : Indicates whether news have finished loading.
- _selectedIndex : Indicates the selected tab on the navigation bar.
- _disconnected : Indicates whether there is internet connection or not.
- loadingBody : Body widget for the loading screen.

##### Methods
- build(context) : Returns a Scaffold with the AppBar on top displaying the title (Mechanical Radio), the page on index from IndexedStack, and the BottomNavigationBar with two items: Radio and Info.
- initState() : Executes createNews() on app start.
- createNews() : 
- checkConnection() :
- _onWillPop() :


#### Radio
- build(context) :
- initState() : Writes the news from the args to its variable, creates forms and initializes the text to speech.
#### MyTextFormField
#### InfoPage

### Web Scraping

### Palette
