# Auto Finance

Auto Finance adalah aplikasi Android untuk mencatat dan memahami arus uang pribadi. Aplikasi dapat membaca notifikasi bank dan e-wallet yang diizinkan, lalu mengubah notifikasi yang dikenali menjadi transaksi. Transaksi, dompet, anggaran, dan data pendukung disimpan di perangkat.

> Proyek ini masih dikembangkan. Hasil pembacaan notifikasi dapat keliru; periksa transaksi dan saldo secara berkala.

## Fitur

- Mencatat transaksi otomatis dari notifikasi dan meninjau notifikasi yang belum cocok atau masih perlu diproses.
- Mengelola transaksi, dompet, transfer, kategori, dan anggaran bulanan maupun mingguan.
- Melihat statistik pemasukan, pengeluaran, arus kas, anggaran, dan saldo dompet.
- Menambah transaksi secara manual dan mengimpor atau mengekspor data transaksi serta dompet dalam CSV.
- Menggunakan model AI lokal untuk membantu membaca notifikasi dari sumber yang dipilih.
- Menampilkan ringkasan saldo dan anggaran melalui widget Android.

## Privasi dan izin

- Akses notifikasi Android diperlukan agar aplikasi dapat membaca notifikasi dan mencatat transaksi. Aktifkan hanya jika kamu setuju Auto Finance membaca notifikasi di perangkat.
- Data transaksi dan dompet disimpan secara lokal di perangkat. Gunakan ekspor CSV untuk membuat cadangan yang dapat dipindahkan.
- Model AI diunduh satu kali ke perangkat. Setelah terpasang, isi notifikasi diproses oleh model lokal dan tidak dikirim ke layanan AI.
- Unduh model memerlukan koneksi internet dan sekitar 347 MB ruang unduh. Model dapat dihapus kembali dari halaman pengaturan AI lokal.
- Fitur pembacaan notifikasi, AI lokal, dan widget memerlukan Android. Parser transaksi bawaan saat ini mengenali format notifikasi BCA, Jago, GoPay/Gojek, dan Shopee/ShopeePay. Sumber lain dapat dicoba melalui AI lokal, tetapi hasilnya bergantung pada format notifikasi dan dompet yang dipilih.

## Mulai menggunakan aplikasi

1. Pasang dan buka Auto Finance di perangkat Android.
2. Buka **Setelan** lalu aktifkan **Akses notifikasi** melalui pengaturan Android.
3. Tambahkan dompet yang ingin dipakai dan sesuaikan saldo awalnya.
4. Untuk AI lokal, buka pengaturan **AI lokal & sumber transaksi**, pilih aplikasi sumber dan dompet, lalu unduh model. Fitur AI tidak berjalan sebelum model selesai diunduh.
5. Periksa halaman transaksi dan riwayat notifikasi. Koreksi kategori atau dompet jika diperlukan.

Nama menu dapat sedikit berubah mengikuti versi aplikasi.

## Menjalankan proyek

### Kebutuhan

- Flutter SDK dengan Dart yang memenuhi batas di `pubspec.yaml` (saat ini Dart `^3.11.4`).
- Android Studio dan Android SDK untuk menjalankan atau membangun aplikasi Android.
- Perangkat Android atau emulator. Untuk perangkat fisik, aktifkan USB debugging jika ingin menjalankan dari komputer.
- Koneksi internet untuk mengambil dependensi pertama kali dan mengunduh model AI.

Proyek ini tidak menyertakan konfigurasi FVM; gunakan perintah `flutter` dari SDK yang terpasang.

### Jalankan

```bash
flutter pub get
flutter run
```

### Periksa dan build APK

```bash
flutter analyze
flutter build apk --release
```

APK release dibuat di `build/app/outputs/flutter-apk/app-release.apk`.

## Struktur kode

```text
lib/
├── app/                    # tema, router, dan navigasi aplikasi
├── core/                   # helper dan layanan lintas fitur
├── data/local/             # database Drift dan tabel bersama
└── features/
    ├── analytics/          # statistik, rincian kategori, dan anggaran bulanan
    ├── dashboard/           # beranda dan ringkasan
    ├── local_ai/            # katalog sumber, layanan model, parser, dan pengaturan AI
    ├── notification/        # riwayat, antrean, dan penanganan notifikasi
    ├── transaction/         # transaksi, parser, kategori, dan pemrosesan tertunda
    ├── wallet/              # dompet dan dampak transaksi ke saldo
    ├── settings/            # pengaturan, impor, dan ekspor
    ├── splash/              # layar awal
    └── debug/               # halaman bantu pengembangan

android/app/src/main/        # NotificationListenerService, widget, dan integrasi AI Android
```

Penyimpanan Flutter menggunakan Drift. Notifikasi diterima oleh layanan Android, disimpan di database Room, lalu disinkronkan dan diproses oleh alur transaksi Flutter. Model AI Android dijalankan di perangkat melalui LiteRT-LM.

## Menelusuri alur transaksi

Untuk memahami atau mengubah perilaku transaksi, titik awal yang berguna:

| Area | Lokasi |
| --- | --- |
| Layanan pembaca notifikasi Android | `android/app/src/main/` |
| Sinkronisasi notifikasi dan daftar antrean | `lib/features/notification/` |
| Parser bawaan dan pipeline transaksi | `lib/features/transaction/domain/usecases/` |
| Bantuan AI lokal untuk parsing | `lib/features/local_ai/` dan `android/app/src/main/kotlin/com/example/auto_finance/LocalAiModelManager.kt` |
| Simpan transaksi dan saldo dompet | `lib/features/transaction/data/dao/` dan `lib/features/wallet/` |
| Statistik dan anggaran | `lib/features/analytics/` |
| Skema database aplikasi | `lib/data/local/tables/` dan `lib/data/local/database/app_database.dart` |
| Navigasi | `lib/app/router.dart` dan `lib/app/navigation/` |
