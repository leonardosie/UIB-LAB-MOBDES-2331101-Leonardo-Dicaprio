import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/movie_provider.dart';
import '../widgets/movie_card.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/error_state_widget.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MovieProvider>().fetchMovies();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();

    return Scaffold(
      backgroundColor:
          isDarkMode ? Colors.black : const Color(0xFFF5F5FA),

      //BOTTOM NAV 
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: provider.currentTab,
        onTap: (index) {
          final provider = context.read<MovieProvider>();

          provider.changeTab(index);

          if (index == 0) {
            provider.setFilter('All'); // reset ke Home
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: "Favorites"),
        ],
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(provider),
            _buildSearchBar(),
            _buildFilterChips(provider),
            _buildOfflineBanner(provider),
            Expanded(child: _buildBody(provider)),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(MovieProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        const Icon(Icons.movie, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Hi Movie',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  // 🌐 LANGUAGE
                  IconButton(
                    icon: const Icon(Icons.language),
                    onPressed: () {
                      provider.toggleLanguage();
                    },
                  ),

                  // 🌙 DARK MODE
                  IconButton(
                    icon: Icon(isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode),
                    onPressed: () {
                      setState(() {
                        isDarkMode = !isDarkMode;
                      });
                    },
                  ),

                  // 📶 OFFLINE
                  IconButton(
                    icon: Icon(
                      provider.forceOffline
                          ? Icons.wifi_off
                          : Icons.wifi,
                      color: provider.forceOffline
                          ? Colors.red
                          : Colors.green,
                    ),
                    onPressed: () {
                      provider.toggleOffline();
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            provider.language == 'en-US'
                ? "Discover what's playing now 🎬"
                : "Temukan film terbaru 🎬",
          ),
        ],
      ),
    );
  }

  // ================= SEARCH =================
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          if (value.isEmpty) {
            context.read<MovieProvider>().clearSearch();
          } else {
            context.read<MovieProvider>().searchMovies(value);
          }
        },
        decoration: InputDecoration(
          hintText: "Search movies...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ================= FILTER =================
  Widget _buildFilterChips(MovieProvider provider) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: provider.filterOptions.length + 1,
        itemBuilder: (context, index) {
          // 🔥 YEAR BUTTON
          if (index == provider.filterOptions.length) {
            return GestureDetector(
              onTap: () => _showYearPicker(provider),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text("Year",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            );
          }

          final filter = provider.filterOptions[index];
          final isSelected =
              provider.selectedFilter == filter;

          return GestureDetector(
            onTap: () => provider.setFilter(filter),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color:
                    isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= YEAR PICKER =================
  void _showYearPicker(MovieProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        final years = [
          "2026",
          "2025",
          "2024",
          "2023",
          "2022",
          "2021",
          "2020-"
        ];

        return ListView(
          children: years.map((year) {
            return ListTile(
              title: Text(
                  year == "2020-" ? "2020 kebawah" : year),
              trailing: provider.selectedYear == year
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                provider.setYear(year);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  // ================= OFFLINE =================
  Widget _buildOfflineBanner(MovieProvider provider) {
    if (!provider.isFromCache) return const SizedBox();

    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      color: Colors.orange,
      child: const Text("you are offline"),
    );
  }

  // ================= BODY =================
  Widget _buildBody(MovieProvider provider) {
    if (provider.status == MovieStatus.loading) {
      return const ShimmerLoading();
    }

    if (provider.status == MovieStatus.error) {
      return ErrorStateWidget(
        message: provider.errorMessage,
        isOffline: false,
        onRetry: () => provider.fetchMovies(),
      );
    }

    // FAVORITES 
    if (provider.currentTab == 1 &&
        provider.movies.isEmpty) {
      return const Center(
        child: Text("No favorite movies yet 💔"),
      );
    }

    if (provider.movies.isEmpty) {
      return const Center(child: Text("No movies found"));
    }

    return ListView.builder(
      itemCount: provider.movies.length,
      itemBuilder: (context, index) {
        final movie = provider.movies[index];

        return MovieCard(
          movie: movie,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    MovieDetailScreen(movie: movie),
              ),
            );
          },
        );
      },
    );
  }
}
