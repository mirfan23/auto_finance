# Auto Finance

Aplikasi Flutter Android untuk mencatat transaksi dari notifikasi bank dan e-wallet, memantau dompet, serta mengelola anggaran.

## Peta kode

```text
lib/
├── app/                              # konfigurasi aplikasi, router, dan navigasi
├── core/                             # helper, model, dan layanan lintas fitur
├── data/local/                       # database Drift dan definisi tabel bersama
└── features/
    ├── transaction/
    │   ├── presentation/{pages,widgets}/
    │   ├── application/providers/     # state dan koordinasi alur transaksi
    │   ├── domain/{entities,usecases}/
    │   └── data/dao/                  # akses transaksi, pending, aturan merchant
    ├── wallet/
    │   ├── presentation/{pages,widgets}/
    │   ├── application/providers/
    │   ├── domain/{entities,usecases}/
    │   └── data/dao/
    ├── notification/
    │   ├── presentation/pages/
    │   ├── application/{providers,services}/
    │   ├── domain/{entities,models}/
    │   └── data/dao/
    ├── analytics/
    │   ├── presentation/{pages,widgets}/
    │   └── data/dao/
    └── dashboard/
        ├── presentation/{pages,widgets}/
        ├── application/providers/
        └── domain/entities/
    ├── settings/presentation/pages/
    ├── splash/presentation/pages/
    └── debug/presentation/pages/
```

Kode dikelompokkan berdasarkan fitur agar halaman, alur aplikasi, aturan bisnis, dan akses datanya mudah ditelusuri. Infrastruktur database Drift tetap di `lib/data/local/` karena dipakai bersama oleh beberapa fitur.

## Menelusuri transaksi

### Transaksi dari notifikasi

```text
Android NotificationListenerService
  → Room menyimpan notifikasi
  → notification/application/providers/notification_sync_provider.dart
  → transaction/application/providers/transaction_provider.dart
  → transaction/domain/usecases/ dan parser/
  → transaction/data/dao/transaction_dao.dart
  → wallet/data/dao/wallet_dao.dart untuk dampak saldo
  → transaction/presentation/pages/transaction_page.dart
```

Listener Android dan database Room berada di `android/app/src/main/`. Database aplikasi Flutter berada di `lib/data/local/`.

### Transaksi manual

Mulai dari `lib/features/transaction/presentation/pages/manual_transaction_page.dart`, lalu ikuti provider transaksi ke use case dan DAO.

## Mencari kode berdasarkan perubahan

| Ingin mengubah | Mulai dari |
| --- | --- |
| Halaman atau tampilan transaksi | `lib/features/transaction/presentation/` |
| State atau koordinasi transaksi | `lib/features/transaction/application/providers/` |
| Cara notifikasi dibaca dan disinkronkan | `lib/features/notification/` dan `android/app/src/main/` |
| Parsing dan aturan transaksi | `lib/features/transaction/domain/usecases/` |
| Penyimpanan transaksi atau saldo | `lib/features/transaction/data/dao/` dan `lib/features/wallet/data/dao/` |
| Statistik dan anggaran | `lib/features/analytics/` |
| Struktur tabel database | `lib/data/local/tables/` dan `lib/data/local/database/app_database.dart` |
| Navigasi dan tab bawah | `lib/app/router.dart` dan `lib/app/navigation/` |

## Menjalankan dan memeriksa

Gunakan Flutter SDK yang ditentukan proyek melalui FVM:

```bash
fvm flutter pub get
fvm flutter run
fvm flutter analyze
```

Untuk build APK Android:

```bash
fvm flutter build apk --release
```
