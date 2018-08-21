import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movies_streams/blocs/bloc_provider.dart';
import 'package:movies_streams/blocs/favorite_bloc.dart';
import 'package:movies_streams/blocs/movie_catalog_bloc.dart';
import 'package:movies_streams/models/movie_card.dart';
import 'package:movies_streams/pages/details.dart';
import 'package:movies_streams/pages/filters.dart';
import 'package:movies_streams/widgets/favorite_icon.dart';
import 'package:movies_streams/widgets/list_summary.dart';
import 'package:movies_streams/widgets/movie_card_widget.dart';

class ListPage extends StatefulWidget {
  @override
  ListPageState createState() {
    return new ListPageState();
  }
}

class ListPageState extends State<ListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final MovieCatalogBloc movieBloc = BlocProvider.of<MovieCatalogBloc>(context);
    final FavoriteBloc favoriteBloc = BlocProvider.of<FavoriteBloc>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('List Page'),
        actions: <Widget>[
          // Icon that gives direct access to the favorites
          // Also displays "real-time", the number of favorites
          StreamBuilder<int>(
            stream: favoriteBloc.outTotalFavorites,
            initialData: 0,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot){
              return FavoriteIcon(counter: snapshot.data);
            }
          ),
          // Icon to open the filters
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              _scaffoldKey.currentState.openEndDrawer();
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          ListSummary(),
          Expanded(
            // Display an infinite GridView with the list of all movies in the catalog,
            // that meet the filters
            child: StreamBuilder<List<MovieCard>>(
                stream: movieBloc.outMoviesList,
                builder: (BuildContext context,
                    AsyncSnapshot<List<MovieCard>> snapshot) {
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return _buildMovieCard(movieBloc, index, snapshot.data, favoriteBloc.outFavorites);
                    },
                    itemCount: (snapshot.data == null ? 0 : snapshot.data.length) + 30,
                  );
                }),
          ),
        ],
      ),
      endDrawer: FiltersPage(),
    );
  }

  Widget _buildMovieCard(
      MovieCatalogBloc movieBloc, int index, List<MovieCard> movieCards, Stream<List<MovieCard>> favoritesStream) {
    // Notify the MovieCatalogBloc that we are rendering the MovieCard[index]
    movieBloc.inMovieIndex.add(index);

    // Get the MovieCard data
    final MovieCard movieCard =
        (movieCards != null && movieCards.length > index) ? movieCards[index] : null;

    if (movieCard == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return MovieCardWidget(
        key: Key('movie_${movieCard.id}'),
        movieCard: movieCard,
        favoritesStream: favoritesStream,
        onPressed: () {
          Navigator
              .of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return DetailsPage(
              data: movieCard,
            );
          }));
        });
  }
}