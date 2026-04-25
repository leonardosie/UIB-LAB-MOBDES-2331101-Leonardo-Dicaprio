import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';

class ApiService {
  static const String _apiKey = '1ee4d7fc9eb24d17b2ecae41b7e635ff';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  // CACHE KEYS
  static const String _cacheNowPlaying = 'cache_now_playing';
  static const String _cachePopular = 'cache_popular';
  static const String _cacheUpcoming = 'cache_upcoming';
  static const String _cacheTopRated = 'cache_top_rated';
  static const String _cacheSearch = 'cache_search_';

  // ===============================
  // 🔥 UNIVERSAL CATEGORY (dipakai provider)
  // ===============================
  Future<List<Movie>> fetchMoviesByCategory(
    String category, {
    String language = 'en-US',
  }) async {
    switch (category) {
      case 'popular':
        return fetchPopularMovies(language: language);
      case 'upcoming':
        return fetchUpcomingMovies(language: language);
      case 'top_rated':
        return fetchTopRatedMovies(language: language);
      default:
        return fetchNowPlayingMovies(language: language);
    }
  }

  // ===============================
  // ENDPOINT METHODS
  // ===============================
  Future<List<Movie>> fetchNowPlayingMovies({String language = 'en-US'}) {
    return _fetchWithCache(
      endpoint: '/movie/now_playing',
      cacheKey: _cacheNowPlaying,
      language: language,
    );
  }

  Future<List<Movie>> fetchPopularMovies({String language = 'en-US'}) {
    return _fetchWithCache(
      endpoint: '/movie/popular',
      cacheKey: _cachePopular,
      language: language,
    );
  }

  Future<List<Movie>> fetchUpcomingMovies({String language = 'en-US'}) {
    return _fetchWithCache(
      endpoint: '/movie/upcoming',
      cacheKey: _cacheUpcoming,
      language: language,
    );
  }

  Future<List<Movie>> fetchTopRatedMovies({String language = 'en-US'}) {
    return _fetchWithCache(
      endpoint: '/movie/top_rated',
      cacheKey: _cacheTopRated,
      language: language,
    );
  }

  // ===============================
  // 🔍 SEARCH
  // ===============================
  Future<List<Movie>> searchMovies(
    String query, {
    String language = 'en-US',
  }) async {
    if (query.trim().isEmpty) {
      return fetchNowPlayingMovies(language: language);
    }

    final cacheKey = '$_cacheSearch${query.toLowerCase().trim()}';

    try {
      final encoded = Uri.encodeComponent(query);

      final response = await http
          .get(
            Uri.parse(
              '$_baseUrl/search/movie?api_key=$_apiKey&language=$language&query=$encoded&page=1',
            ),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        await _saveCache(cacheKey, response.body);

        final data = json.decode(response.body);
        final List results = data['results'] ?? [];

        return results.map((e) => Movie.fromJson(e)).toList();
      } else {
        throw Exception('Search API error: ${response.statusCode}');
      }
    } catch (e) {
      // fallback cache
      return await _loadFromCache(cacheKey);
    }
  }

  // ===========
  //  CORE FETCH 
  // ===========
  Future<List<Movie>> _fetchWithCache({
    required String endpoint,
    required String cacheKey,
    required String language,
  }) async {
    try {
      final url =
          '$_baseUrl$endpoint?api_key=$_apiKey&language=$language&page=1';

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        await _saveCache(cacheKey, response.body);

        final data = json.decode(response.body);
        final List results = data['results'] ?? [];

        return results.map((e) => Movie.fromJson(e)).toList();
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      // 🔥 fallback ke cache (offline readiness)
      return await _loadFromCache(cacheKey);
    }
  }

  // ===============================
  // 💾 CACHE
  // ===============================
  Future<void> _saveCache(String key, String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, data);
  }

  Future<List<Movie>> _loadFromCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(key);

    if (cached != null) {
      final data = json.decode(cached);
      final List results = data['results'] ?? [];

      return results.map((e) => Movie.fromJson(e)).toList();
    }

    return [];
  }
}
