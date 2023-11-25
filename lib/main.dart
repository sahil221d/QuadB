import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
  
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  List<dynamic> movies = [];
  double opacityLevel = 0.0; 

  @override
  void initState() {
    super.initState();
    fetchMovies();
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        opacityLevel = 1.0;
      });
    });
  }

  Future<void> fetchMovies() async {
    try {
      final response = await http.get(Uri.parse('https://api.tvmaze.com/search/shows?q=all'));
      if (response.statusCode == 200) {
        setState(() {
          movies = json.decode(response.body);
        });
        navigateToHomeScreen();
      } else {
        throw Exception('Failed to load movies');
      }
    } catch (e) {
      print('Error fetching movies: $e');
      navigateToHomeScreen();
    }
  }

  void navigateToHomeScreen() {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(movies)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          duration: Duration(seconds: 1),
          opacity: opacityLevel,
          child: Image.asset('assets/Image1.png'),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<dynamic> movies;

  HomeScreen(this.movies);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MovieZ', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsScreen(movies[index]),
                ),
              );
            },
            child: Card(
              elevation: 5.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: movies[index]['show'] != null &&
                            movies[index]['show']['image'] != null &&
                            movies[index]['show']['image']['medium'] != null
                        ? Image.network(
                            movies[index]['show']['image']['medium'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                            
                              return Image.asset(
                                'assets/Image1.png',
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            'assets/Image1.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      movies[index]['show'] != null &&
                              movies[index]['show']['name'] != null
                          ? movies[index]['show']['name']
                          : 'No Name',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen()),
            );
          }
        },
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> searchResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: _onSearchTextChanged,
          decoration: InputDecoration(
            hintText: 'Search movies',
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _searchMovies(_searchController.text);
            },
          ),
        ],
      ),
      body: _buildSearchResults(),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    if (searchResults.isEmpty) {
      
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/Duck.gif', 
              width: 100,
              height: 100,
            ),
            SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    } else {
     
      return ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsScreen(searchResults[index]),
                ),
              );
            },
            title: Text(
              searchResults[index]['show']['name'] ?? '',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            leading: _buildLeadingImage(searchResults[index]),
          );
        },
      );
    }
  }

  Widget _buildLeadingImage(dynamic result) {
    String imageUrl = result['show']['image']?['medium'] ?? '';
    if (imageUrl.isNotEmpty && Uri.parse(imageUrl).isAbsolute) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: 50,
        height: 50,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/Image1.png',
            fit: BoxFit.cover,
            width: 50,
            height: 50,
          );
        },
      );
    } else {
      return Image.asset(
        'assets/Image1.png',
        fit: BoxFit.cover,
        width: 50,
        height: 50,
      );
    }
  }

  void _onSearchTextChanged(String searchText) {
    _searchMovies(searchText);
  }

  void _searchMovies(String searchTerm) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.tvmaze.com/search/shows?q=${searchTerm}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          searchResults = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to search movies');
      }
    } catch (e) {
      print('Error searching movies: $e');
    }
  }
}

class DetailsScreen extends StatelessWidget {
  final dynamic movie;

  DetailsScreen(this.movie);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          movie['show']['name'] ?? '',
          style: TextStyle(
            decoration: TextDecoration.underline,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: movie['show']['image'] != null &&
                      movie['show']['image']['original'] != null
                  ? Image.network(
                      movie['show']['image']['original'],
                      fit: BoxFit.cover,
                      width: 200,
                      height: 300,
                    )
                  : Image.asset(
                      'assets/Image1.png',
                      fit: BoxFit.cover,
                      width: 200,
                      height: 300,
                    ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Type: ${movie?['show']['type'] ?? ''}',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Language: ${movie?['show']['language'] ?? ''}',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Genres: ${movie?['show']['genres']?.join(", ") ?? ''}',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Status: ${movie?['show']['status'] ?? ''}',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Premiered: ${movie?['show']['premiered'] ?? ''}',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Average Rating: ${movie?['show']['rating']['average'] ?? 'N/A'}',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Summary:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              stripHtmlTags(movie['show']['summary'] ?? ''),
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen()),
            );
          }
        },
      ),
    );
  }

  String stripHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, '');
  }
}
