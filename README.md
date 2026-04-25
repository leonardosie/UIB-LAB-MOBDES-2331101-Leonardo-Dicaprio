<<<<<<< HEAD
# uts_flutter_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
=======
## UIB-LAB-MOBDES-2331101-Leonardo-Dicaprio
## 🎬 Hi Movie App

Hi Movie App adalah aplikasi mobile berbasis Flutter yang menampilkan daftar film menggunakan TMDB API.

---

## Fitur Utama

* Menampilkan film (Now Playing, Popular, Upcoming, Top Rated)
* Search film berdasarkan judul
* Filter (rating & tahun)
* Favorite (runtime)
* Offline mode (cache)
* Shimmer loading
* Dark mode
* Multi-language (EN / ID)

---

##  Struktur Folder

```
lib/
├── models/
│   └── movie.dart
├── services/
│   └── api_service.dart
├── providers/
│   └── movie_provider.dart
├── views/
│   ├── screens/
│   │   └── home_screen.dart
│   └── widgets/
│       ├── movie_card.dart
│       ├── shimmer_loading.dart
│       └── error_state_widget.dart
```

### Penjelasan:

* **models** → representasi data (Movie)
* **services** → komunikasi dengan API TMDB
* **providers** → state management (logic aplikasi)
* **views** → tampilan UI

---

##  State Management

Aplikasi ini menggunakan **Provider** sebagai state management.

### Alasan menggunakan Provider:

* Mudah dipahami dan cocok untuk pemula
* Terintegrasi langsung dengan Flutter
* Ringan dan tidak kompleks
* Cukup untuk skala aplikasi ini

Provider digunakan untuk:

* Mengelola data film
* Mengatur filter & search
* Mengelola favorite
* Menangani state (loading, error, offline)

---

##  API

Data diambil dari:
https://www.themoviedb.org/

Endpoint yang digunakan:

* /movie/now_playing
* /movie/popular
* /movie/upcoming
* /movie/top_rated
* /search/movie

##  Cara Menjalankan

1. Clone repository
2. Jalankan perintah:


flutter pub get
flutter run

##  Author

Leonardo Dicaprio
>>>>>>> 00e999b4fbf343346d26560b5d35717c03ae8265
