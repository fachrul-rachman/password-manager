# Teaching Guide – Password Manager (Flutter + BLoC + MockAPI)

Dokumen ini ditujukan untuk **pengajar/mentor** yang ingin menggunakan project ini sebagai bahan ajar.

---

## 1. Konsep yang Dipelajari
- **Flutter UI**: membangun tampilan dengan widget, form, list, dan navigasi.
- **State Management**: menggunakan `flutter_bloc` untuk mengelola event & state.
- **CRUD Operations**: Create, Read, Update, Delete data lewat REST API (MockAPI).
- **Separation of Concerns**: memisahkan model, repository, bloc, dan UI.

---

## 2. Struktur Folder
```

lib/
blocs/          # Event, State, Bloc (PasswordBloc)
models/         # PasswordModel (representasi data)
repositories/   # PasswordsRepository (akses API)
ui/
pages/        # Halaman utama (list, form)
widgets/      # Widget kecil reusable (tile, empty, error)

```

**Catatan untuk menjelaskan ke murid:**
- `models/` → “ini blueprint data”
- `repositories/` → “ini jembatan antara app dengan API”
- `blocs/` → “otak yang menghubungkan event dari UI dengan data dari repository”
- `ui/` → “tempat tampilan aplikasi”

---

## 3. Alur Kerja Aplikasi
1. **User berinteraksi dengan UI**  
   → menekan tombol tambah, edit, hapus, atau refresh.  

2. **UI memicu Event ke BLoC**  
   → contoh: `PasswordAdded`, `PasswordDeleted`, dll.  

3. **BLoC memanggil Repository**  
   → repository melakukan request HTTP ke MockAPI.  

4. **Repository mengembalikan data (atau error)**  
   → BLoC memproses hasil dan emit State baru.  

5. **UI mendengarkan State**  
   → menampilkan daftar, loading, error, atau tampilan kosong.

---

## 4. Tips Mengajar
- Mulai dari **alur data sederhana**: Model → Repository → BLoC → UI.
- Tunjukkan **perubahan state** dengan `BlocBuilder`.
- Praktikkan **menambah & menghapus** data di MockAPI agar murid melihat hasil nyata.
- Dorong murid untuk mencoba **mengubah desain UI** atau **menambah field baru** di MockAPI.

---

## 5. Tools yang Dipakai
- [Flutter](https://flutter.dev/)
- [flutter_bloc](https://pub.dev/packages/flutter_bloc)
- [MockAPI](https://mockapi.io)
- [icon.horse](https://icon.horse) untuk logo otomatis
```
