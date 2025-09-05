
# Setup Project

## 1. Clone & Install
1. Clone repository ini:
   ```bash
   git clone https://github.com/fachrul-rachman/password-manager.git
   cd password-manager
   ```


2. Install dependencies Flutter:

   ```bash
   flutter pub get
   ```

## 2. Setup MockAPI

1. Buka [https://mockapi.io](https://mockapi.io) dan login/daftar.
2. Buat **New Project** → beri nama misalnya `password-manager`.
3. Tambahkan resource baru bernama `passwords`.
4. Tambahkan field berikut:

   * `title` (string)
   * `email` (string)
   * `password` (string)
   * `imageUrl` (string)
5. Simpan dan catat **Base URL** project kamu. Contoh:

   ```
   https://64xxxxxx.mockapi.io/api/v1
   ```

## 3. Konfigurasi Base URL

1. Buka file `lib/main.dart`.
2. Ganti variabel `_baseUrl` dengan Base URL MockAPI kamu:

   ```dart
   static const String _baseUrl = 'https://64xxxxxx.mockapi.io/api/v1';
   ```

## 4. Jalankan Project

1. Pastikan device/emulator sudah jalan.
2. Jalankan perintah:

   ```bash
   flutter run
   ```
3. Aplikasi akan menampilkan daftar password dari MockAPI.
