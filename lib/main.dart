import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
//logical pixels as a unit of length
//(roughly 38 logical pixels per centimeter)

void main() {
  runApp(MyApp());
}

// create app-wide state
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // widget -- root of the application
  @override
  Widget build(BuildContext context) {
    //ChangeNotifierProvider: state is created and provided to the whole app
    return ChangeNotifierProvider(
      //alow any widge--get hold of the state
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

//MyAppState: defines the data the app needs to function
//extendsChangeNotifier: notify others about its own changes
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

//some state is only relevant to a single widget
class MyHomePage extends StatefulWidget {
  //IDE crates a new class: _MyHomePageState()
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

//_MyHomePageState() extends State -- manage own values
class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
        //change the widget tree depending on how much available space
        builder: (context, constraints) {
      //callback is called every time the constraints change
      return Scaffold(
        //Scaffold: the basic material design visual layout structure
        //framework
        body: Row(
          children: [
            // safeArea wraps around NavigationRail
            SafeArea(
              //widget
              //child is not obscured bby a hardware notch or a status bar
              child: NavigationRail(
                //Navigation buttons
                extended: constraints.maxWidth >= 600, //label next to the icons
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                //callback: defines what happens
                //when the user select one of the destinations
                onDestinationSelected: (value) {
                  //value: the requested index value
                  setState(() {
                    // tells the Flutter framework
                    // that something has changed in this State
                    // rerun the build method --display the updated values
                    selectedIndex = value;
                  });
                },
              ),
            ),
            //expressing the layouts where some children(NavigationRail)
            //take only as much space as they need
            //other widgets(Expanded) take as much of the remaining room
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have' '${appState.favorites.length} favorites'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

// content of the MyHomePage
class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      // A widget that centers its child within itself
      // Column, Row, Container (single child)
      child: Column(
        // mainAxisAlignment: control
        // how a row or column aligns its children
        // column: the main axis runs vertically
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// class MyHomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     var appState = context.watch<MyAppState>();
//     var pair = appState.current;

//     IconData icon;
//     icon = Icons.favorite;
//     if (appState.favorites.contains(pair)) {
//       icon = Icons.favorite;
//     } else {
//       icon = Icons.favorite_border;
//     }

//     return Scaffold(
//       //top-level widget
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             //text widget no longer refers to the whole appState
//             BigCard(pair: pair),
//             //SizedBox widget: takes space--visual 'gaps'
//             SizedBox(height: 10),
//             Row(
//               //not to take all available horizontal space
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 ElevatedButton.icon(
//                     onPressed: () {
//                       appState.toggleFavorite();
//                     },
//                     icon: Icon(icon),
//                     label: Text('Like')),
//                 SizedBox(width: 10),
//                 ElevatedButton(
//                   onPressed: () {
//                     appState.getNext();
//                   },
//                   child: Text('Next'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  // Fields in a Widget subclass are always marked "final".
  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    // app's current theme
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimary);

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        //padding widget around the text widget
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
