# LapangIN

## 👥 Nama-nama Anggota Kelompok

- **Flora Cahaya Putri** – 2406350955
- **Marlond Leanderd Batara** – 2406496201
- **Muhammad Fauzan** – 2406496302
- **Nadila Salsabila Fauziyyah** – 2406425590
- **Rayyan Akbar Gumilang** – 2406496422

---

## 📝 Deskripsi Aplikasi

**LapangIN** adalah aplikasi yang dikembangkan untuk mempermudah proses penyewaan lapangan olahraga.  
Aplikasi ini berfungsi sebagai penghubung antara **mitra (pemilik lapangan)** dan **penyewa** yang ingin melakukan pemesanan lapangan olahraga seperti futsal, badminton, basket, padel, dan tenis.

Dengan **LapangIN**, mitra mendapatkan peluang untuk menambah pemasukan serta meningkatkan visibilitas lapangan mereka.  
Sementara itu, penyewa mendapatkan kemudahan dalam mencari, memilih, dan melakukan reservasi secara online.  
**Admin** berperan penting dalam menjaga kualitas sistem dengan memverifikasi mitra serta memantau aktivitas transaksi dan data.

---

## ⚙️ **Daftar Modul yang Akan Diimplementasikan**

### 1. Modul Booking & Pembayaran (User) -> Muhammad Fauzan

Menangani seluruh proses pemesanan lapangan oleh **Penyewa (User)**, mulai dari pemilihan jadwal hingga konfirmasi pembayaran.
**Fitur Utama:**

- Pemesanan lapangan dengan memilih venue, jenis lapangan, dan jadwal tersedia
- Melihat daftar & riwayat booking beserta detail waktu, harga, dan status pembayaran
- Mengubah atau membatalkan booking selama belum melewati batas waktu yang ditentukan
- Melakukan proses pembayaran agar lapangan berstatus _ter-booking_ secara resmi

---

### 2. Modul Manajemen Lapangan (Mitra) -> Rayyan Akbar Gumilang

Digunakan oleh **Mitra** untuk mengelola lapangan yang berada di dalam venue miliknya serta memantau aktivitas penyewaan.
**Fitur Utama:**

- Tambah, edit, dan hapus data lapangan (court) di dalam venue
- Mengatur detail lapangan: jenis olahraga, harga, jadwal ketersediaan, dan status aktif
- Sistem otomatis mencatat pendapatan berdasarkan hasil booking yang dilakukan pengguna
- Melihat riwayat dan catatan seluruh pesanan untuk setiap lapangan

---

### 3. Modul Admin & Verifikasi Mitra -> Flora Cahaya Putri

Digunakan oleh **Admin** untuk mengelola aktivitas sistem, khususnya terkait verifikasi Mitra, transaksi, dan refund.
**Fitur Utama:**

- Verifikasi Mitra & Venue (ACC atau tolak pendaftaran setelah meninjau detail deskripsi dan gambar)
- Melihat total pendapatan Mitra berdasarkan hasil transaksi penyewaan lapangan
- Membuat create manual refund untuk pengembalian dana booking
- Membatalkan atau menghapus permintaan refund yang tidak disetujui
- Meninjau seluruh data Mitra yang terdaftar beserta detail venue dan status verifikasi

---

### 4. Modul Manajemen Profil & Venue (User & Mitra) -> Marlond Leanderd Batara

Digunakan oleh **User dan Mitra** untuk mengelola data profil serta mengatur informasi venue yang dimiliki oleh Mitra.
**Fitur Utama:**

- **Edit Profil:** Mengubah username, nama depan & belakang, serta foto profil
- **Hapus Akun:** Menghapus akun secara permanen dari sistem
- **Manajemen Venue (Mitra):**

  - Tambah venue baru dengan data seperti nama, lokasi, jenis olahraga, harga, dan deskripsi
  - Edit venue (nama, harga rata-rata, deskripsi, kategori olahraga, dan maintenance)
  - Hapus venue (otomatis menghapus seluruh court yang terkait dengan venue tersebut)

---

### 5. Modul Katalog & Detail Venue -> Nadila Salsabila Fauziyyah

Menampilkan daftar venue olahraga yang tersedia dan menyediakan fitur pencarian serta informasi detail setiap venue.
**Fitur Utama:**

- Menampilkan daftar venue lengkap (foto, nama, lokasi, rating, dan harga)
- Pencarian & filter berdasarkan nama, lokasi, rating, dan rentang harga
- Halaman detail menampilkan foto, deskripsi, fasilitas, harga, jadwal ketersediaan, dan review pengguna
- **Review:** Pengguna yang sudah booking dapat membuat, mengubah, dan menghapus review secara langsung di halaman detail venue

---

## 📊 Sumber Initial Dataset Kategori Utama Produk

- [https://www.gelora.id/](https://www.gelora.id/)
- [https://ayo.co.id/](https://ayo.co.id/)
- [https://www.google.com/maps](https://www.google.com/maps)

---

## 👤 Role atau Peran Pengguna

### Mitra

Pemilik atau pengelola lapangan olahraga yang ingin menyewakan fasilitasnya kepada masyarakat.  
**Fitur Mitra:**

- Menambahkan data lapangan (nama, jenis olahraga, harga, lokasi)
- Melihat status booking yang masuk
- Memantau pemasukan dan laporan transaksi

---

### Penyewa (User)

Pengguna aplikasi yang ingin mencari dan menyewa lapangan olahraga sesuai kebutuhan.  
**Fitur Penyewa:**

- Mencari lapangan berdasarkan olahraga, lokasi, atau harga
- Melakukan booking lapangan
- Melakukan pembayaran secara online

---

### Admin

Pengelola sistem yang bertugas menjaga kelancaran operasional dan keamanan data.  
**Fitur Admin:**

- Verifikasi mitra dan data lapangan
- Mengelola aktivitas dan transaksi
- Melakukan logging aktivitas mitra dan penyewa

---

## 🔗 Alur Pengintegrasian dengan Web Service Django

Aplikasi mobile **LapangIN** terintegrasi dengan aplikasi web Django yang telah dibuat pada Proyek Tengah Semester. Berikut adalah alur integrasinya:

### 1. **Setup Koneksi HTTP**

- Menggunakan package `http` atau `dio` untuk melakukan request ke Django backend
- Menambahkan base URL dari deployment Django (PWS) sebagai endpoint API
- Mengatur header yang diperlukan (Content-Type, Authorization, CSRF token)

### 2. **Autentikasi & Session Management**

- **Login/Register:** Mengirim credentials ke endpoint Django `/auth/login/` atau `/auth/register/`
- Menyimpan session cookie atau token yang diterima dari Django menggunakan `shared_preferences` atau `flutter_secure_storage`
- Menyertakan token/cookie pada setiap request untuk autentikasi

### 3. **Fetching Data (GET Request)**

- Mengambil data venue, lapangan, dan booking dari endpoint Django yang sudah ada
- Parsing response JSON menggunakan model class Dart dengan factory constructor `fromJson()`
- Menampilkan data menggunakan `FutureBuilder` atau state management (Provider, Bloc, Riverpod)

### 4. **Mengirim Data (POST/PUT/DELETE Request)**

- **Create:** Mengirim data baru (booking, review, venue) ke endpoint Django dengan method POST
- **Update:** Mengupdate data existing dengan method PUT/PATCH
- **Delete:** Menghapus data dengan method DELETE
- Encoding data ke format JSON menggunakan method `toJson()` dari model class

### 5. **Error Handling & Response**

- Menangani berbagai status code HTTP (200, 201, 400, 401, 404, 500)
- Menampilkan pesan error yang user-friendly
- Implementasi loading state dan error state pada UI

### 6. **Serialisasi Data**

- Membuat model class Dart yang sesuai dengan struktur model Django
- Menggunakan code generation tools seperti `json_serializable` untuk otomasi serialization
- Memastikan format data (datetime, decimal) compatible antara Django dan Flutter

### Contoh Alur Request:

```
Flutter App → HTTP Request → Django Backend (PWS)
                ↓
Django memproses (Views + Models)
                ↓
Django Response (JSON) → Flutter menerima & parse
                ↓
Update UI dengan data baru
```

---

## Tautan Deployment & Desain

- **Link Design (Figma):** [https://www.figma.com/team_invite/redeem/H4djMUeJW2NmihEoMSnvd2](https://www.figma.com/team_invite/redeem/H4djMUeJW2NmihEoMSnvd2)
- **Deployment (PWS):** [https://muhammad-fauzan44-lapangin.pbp.cs.ui.ac.id/](https://muhammad-fauzan44-lapangin.pbp.cs.ui.ac.id/)
