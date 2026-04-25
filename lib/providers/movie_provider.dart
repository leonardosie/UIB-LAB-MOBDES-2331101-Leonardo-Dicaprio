import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie.dart';
import '../services/api_service.dart';

enum MovieStatus { initial, loading, loaded, error, offline }

class MovieProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Movie> _allMovies = [];
  List<Movie> _filteredMovies = [];

  MovieStatus _status = MovieStatus.initial;
  String _errorMessage = '';

  String _selectedFilter = 'All';
  String _selectedYear = '';

  bool _isFromCache = false;

  // 🔥 CATEGORY API
  String _selectedCategory = 'now_playing';

  // 🔥 LANGUAGE (TMDB REAL)
  String _language = 'en-US';
  String get language => _language;

  void toggleLanguage() {
    _language = _language == 'en-US' ? 'id-ID' : 'en-US';
    fetchMovies();
  }

  // 🔥 FAVORITE (runtime)
  final List<Movie> _favorites = [];
  List<Movie> get favorites => _favorites;

  void toggleFavorite(Movie movie) {
    if (_favorites.any((m) => m.id == movie.id)) {
      _favorites.removeWhere((m) => m.id == movie.id);
    } else {
      _favorites.add(movie);
    }
    notifyListeners();
  }

  bool isFavorite(Movie movie) {
    return _favorites.any((m) => m.id == movie.id);
  }

  // 🔥 TAB (Home / Favorite)
  int _currentTab = 0;
  int get currentTab => _currentTab;

  void changeTab(int index) {
    _currentTab = index;
    notifyListeners();
  }

  // 🔥 FORCE OFFLINE
  bool _forceOffline = false;
  bool get forceOffline => _forceOffline;

  void toggleOffline() {
    _forceOffline = !_forceOffline;
    fetchMovies();
  }

  // ==========================
  // GETTERS
  // ==========================
  List<Movie> get movies =>
      _currentTab == 0 ? _filteredMovies : _favorites;

  MovieStatus get status => _status;
  String get errorMessage => _errorMessage;
  String get selectedFilter => _selectedFilter;
  bool get isFromCache => _isFromCache;
  String get selectedYear => _selectedYear;

  final List<String> filterOptions = [
    'All',
    'Popular',
    'Upcoming',
    'High Rated',
    'Low Rated',
  ];

  // =============
  //  FETCH MOVIES
  // =============
  Future<void> fetchMovies() async {
    _status = MovieStatus.loading;
    _isFromCache = false;
    _errorMessage = '';
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    try {
      if (_forceOffline) throw Exception("Forced offline");

      List<Movie> movies = [];

      // 🔥 PANGGIL API SESUAI CATEGORY
      switch (_selectedCategory) {
        case 'popular':
          movies = await _apiService.fetchPopularMovies(language: _language);
          break;
        case 'upcoming':
          movies = await _apiService.fetchUpcomingMovies(language: _language);
          break;
        case 'top_rated':
          movies = await _apiService.fetchPopularMovies(language: _language); // fallback
          break;
        default:
          movies = await _apiService.fetchNowPlayingMovies(language: _language);
      }

      // ✅ CACHE
      final movieJson = movies.map((e) => e.toJson()).toList();
      await prefs.setString('cached_movies', jsonEncode(movieJson));

      _allMovies = movies;
      _status = MovieStatus.loaded;

      _applyFilters();
    } catch (e) {
      final cachedData = prefs.getString('cached_movies');

      if (cachedData != null) {
        final List decoded = jsonDecode(cachedData);

        _allMovies = decoded.map((e) => Movie.fromJson(e)).toList();

        _status = MovieStatus.offline;
        _isFromCache = true;
        _errorMessage = 'Offline mode — showing cached data';

        _applyFilters();
      } else {
        _status = MovieStatus.error;
        _errorMessage = 'No internet & no cached data.';
        notifyListeners();
      }
    }
  }

  // ==========
  //  SEARCH 
  // ==========
  Future<void> searchMovies(String query) async {
    _status = MovieStatus.loading;
    notifyListeners();

    try {
      if (_forceOffline) throw Exception("Forced offline");

      final results =
          await _apiService.searchMovies(query, language: _language);

      _allMovies = results;
      _status = MovieStatus.loaded;

      _applyFilters();
    } catch (e) {
      _status = MovieStatus.error;
      _errorMessage = 'Search failed.\nCheck connection.';
      notifyListeners();
    }
  }

  // =================
  //  FILTER BUTTON 
  // =================
  void setFilter(String filter) {
    _selectedFilter = filter;

    switch (filter) {
      case 'Popular':
        _selectedCategory = 'popular';
        break;
      case 'Upcoming':
        _selectedCategory = 'upcoming';
        break;
      case 'High Rated':
        _selectedCategory = 'top_rated';
        break;
      default:
        _selectedCategory = 'now_playing';
    }

    fetchMovies();
  }

  // ============
  //  YEAR FILTER 
  // ============
  void setYear(String year) {
    if (_selectedYear == year) {
      _selectedYear = ''; // reset kalau klik lagi
    } else {
      _selectedYear = year;
    }

    _applyFilters();
  }

  // ==========================
  //  APPLY FILTER 
  // ==========================
  void _applyFilters() {
    List<Movie> result = List.from(_allMovies);

    // LOW RATED (lokal)
    if (_selectedFilter == 'Low Rated') {
      result = result.where((m) => m.voteAverage < 6.0).toList();
    }

    // YEAR FILTER
    if (_selectedYear.isNotEmpty) {
      if (_selectedYear == '2020-') {
        result = result.where((m) {
          final year = int.tryParse(m.year) ?? 0;
          return year <= 2020;
        }).toList();
      } else {
        result = result.where((m) => m.year == _selectedYear).toList();
      }
    }

    _filteredMovies = result;
    notifyListeners();
  }

  // ==========================
  void clearSearch() {
    fetchMovies();
  }
}
