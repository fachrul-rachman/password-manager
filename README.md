```markdown
# Password Manager (Flutter + BLoC + MockAPI)

Project ini adalah aplikasi sederhana untuk belajar **Flutter**, **state management dengan BLoC**, dan **CRUD menggunakan REST API** (MockAPI).  
Aplikasi ini memungkinkan pengguna untuk menyimpan daftar akun/password secara sederhana.

## Tujuan
- Sebagai bahan ajar untuk pengajar/mentor yang ingin menjelaskan konsep Flutter & BLoC.
- Memberikan contoh nyata penggunaan CRUD (Create, Read, Update, Delete) dengan REST API.
- Memberikan gambaran struktur project Flutter yang rapi namun tetap sederhana.

## Fitur
- Melihat daftar password.
- Menambahkan password baru.
- Mengedit password.
- Menghapus password (dengan konfirmasi).
- Logo aplikasi otomatis diambil dari [icon.horse](https://icon.horse).

## Struktur Project
```

lib/
blocs/          # Event, State, Bloc untuk Passwords
models/         # Data model (PasswordModel)
repositories/   # Repository untuk komunikasi dengan MockAPI
ui/
pages/        # Halaman (list, form)
widgets/      # Widget kecil reusable (tile, empty view, error view)

```

## Dokumen Lain
- [SETUP.md](SETUP.md) → cara menjalankan project dan setup MockAPI.  
- [GUIDE.md](GUIDE.md) → panduan mengajar & penjelasan arsitektur project.  
```
