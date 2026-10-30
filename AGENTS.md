# Auto Finance — Codex Project Instructions

## 1. Project Overview

Auto Finance adalah aplikasi Flutter Android untuk mencatat transaksi keuangan berdasarkan notification yang diterima dari aplikasi perbankan/e-wallet.

Target utama aplikasi:

- Membaca notification Android menggunakan `NotificationListenerService`.
- Menyimpan notification secara lokal agar tidak hilang ketika Flutter tidak aktif.
- Memproses notification menjadi transaksi.
- Mendeteksi transaksi duplicate.
- Menangani transfer antar-wallet melalui pairing debit/credit.
- Menyimpan transaksi ke database lokal.
- Mengubah saldo wallet berdasarkan transaksi.
- Mendukung recovery ketika aplikasi Flutter di-kill atau tidak sedang terbuka.

Project menggunakan:

- Flutter
- Dart
- Kotlin
- Android `NotificationListenerService`
- Room untuk notification log di Android
- Drift untuk database utama Flutter
- Riverpod untuk dependency injection/state management

---

# 2. IMPORTANT WORKING RULES

## 2.1 Do NOT make broad changes without analysis

Sebelum mengubah kode:

1. Pahami file yang berkaitan.
2. Telusuri caller dan dependency.
3. Jelaskan masalah yang ditemukan.
4. Identifikasi file yang akan diubah.
5. Ubah seminimal mungkin.
6. Setelah perubahan, jalankan static analysis/test yang relevan.

Jangan melakukan refactor besar hanya karena kode terlihat dapat dirapikan.

Prioritaskan:

- correctness
- data integrity
- reliability
- backward compatibility
- minimal changes

di atas code style atau refactoring.

---

## 2.2 Preserve the existing architecture

Jangan mengganti architecture utama tanpa alasan kuat.

Architecture saat ini:

```text
Android NotificationListenerService
        │
        ▼
Room notification_logs
        │
        ▼
Flutter startup synchronization
        │
        ▼
NotificationSyncProvider
        │
        ▼
TransactionAction
        │
        ▼
TransactionPipeline
        │
        ▼
PendingTransaction
        │
        ├───────────────┐
        │               │
        ▼               ▼
Pairing Transfer    Finalize Single
        │               │
        ▼               ▼
   Transaction       Transaction
        │               │
        └───────┬───────┘
                ▼
          Wallet Balance
```

Jangan memindahkan tanggung jawab antar-layer kecuali memang diperlukan.

---

# 3. Project Structure

Struktur utama:

```text
auto_finance/
├── android/
│   └── app/
│       └── src/
│           └── main/
│               ├── AndroidManifest.xml
│               └── kotlin/
│                   └── com/example/auto_finance/
│                       ├── MainActivity.kt
│                       ├── NotificationListener.kt
│                       ├── BootReceiver.kt
│                       ├── DbProvider.kt
│                       └── data/
│                           ├── AppDatabase.kt
│                           ├── NotificationDao.kt
│                           └── NotificationEntity.kt
│
├── lib/
│   ├── data/
│   │   ├── dao/
│   │   └── local/
│   │       ├── database/
│   │       └── tables/
│   │
│   ├── domain/
│   │   ├── entities/
│   │   └── usecases/
│   │
│   └── features/
│       ├── notification/
│       ├── transaction/
│       └── wallet/
│
├── test/
├── pubspec.yaml
└── AGENTS.md
```

Do not assume this structure is complete.

Always inspect the repository before making structural decisions.

---

# 4. Android Notification Architecture

## 4.1 NotificationListenerService

Main Android notification entry point:

```text
NotificationListener.kt
```

Responsibilities:

- Receive Android notifications.
- Extract:
  - packageName
  - title
  - text
  - timestamp
- Store notification into Room.
- Optionally forward notification to Flutter through EventChannel when Flutter is alive.

Important:

`NotificationListenerService` must NOT depend on Flutter UI being alive.

The Android service must be able to receive and persist notifications even when:

- Flutter application is not open.
- MainActivity is destroyed.
- Flutter engine is not running.
- App UI is not running.

The Room database is therefore a persistence/recovery layer.

---

# 5. Room Notification Database

Android Room database contains:

```text
notification_logs
```

Entity:

```text
NotificationEntity
```

Current fields:

```text
id
packageName
title
text
timestamp
processed
```

DAO:

```text
NotificationDao
```

Important rule:

A notification should NOT be marked `processed = true` until Flutter successfully processes the notification.

If processing fails:

```text
processed remains false
```

so the notification can be retried later.

---

# 6. Flutter Notification Synchronization

Flutter accesses Android Room using:

```text
notification_db_service.dart
```

MethodChannel:

```text
notification_db
```

Available operations:

```text
getPendingNotifications
markNotificationProcessed
```

Startup synchronization:

```text
StartupSyncService
```

which invokes:

```text
NotificationSyncProvider.sync()
```

Flow:

```text
Flutter starts
      ↓
StartupSyncService
      ↓
NotificationSyncProvider.sync()
      ↓
NotificationDbService.getPendingNotifications()
      ↓
TransactionAction.handle()
      ↓
success?
   │
   ├── YES → markNotificationProcessed()
   │
   └── NO  → DO NOT mark processed
```

---

# 7. EventChannel

EventChannel:

```text
notif_stream
```

is only a real-time communication mechanism.

It must NOT be treated as the primary persistence mechanism.

When Flutter is alive:

```text
NotificationListener
        ↓
EventChannel
        ↓
Flutter
```

When Flutter is not alive:

```text
NotificationListener
        ↓
Room
        ↓
Startup Sync
```

The Room database is the source of recovery for notifications.

---

# 8. Main Transaction Pipeline

Main entry:

```text
TransactionAction
```

Current flow:

```text
Map notification
      ↓
TransactionPipelineUseCase
      ↓
ParserDispatcher
      ↓
Transaction
      ↓
WalletResolver
      ↓
PendingTransactionDao
      ↓
TransferPairingUseCase
      ↓
FinalizePendingUseCase
      ↓
SaveTransactionUseCase
      ↓
ApplyTransactionUseCase
      ↓
WalletDao
```

---

# 9. TransactionPipelineUseCase

File:

```text
lib/domain/usecases/transaction/transaction_pipeline_usecase.dart
```

Responsibilities:

- Receive notification data.
- Send notification to parser.
- Convert parser result into domain `Transaction`.

If parser returns null:

```text
notification is not a valid transaction
```

Do not create a fake transaction.

---

# 10. Pending Transactions

Database:

```text
PendingTransactionsTable
```

DAO:

```text
PendingTransactionDao
```

Pending transaction exists because:

1. Transfer transactions may arrive as separate debit and credit notifications.
2. A transaction may need to wait before being finalized.
3. The app may be killed during processing.
4. Recovery must be possible without losing transaction data.

Pending transaction should not be deleted until the transaction has been successfully finalized.

---

# 11. Transfer Pairing

Transfers can consist of:

```text
Debit notification
+
Credit notification
```

Pairing is handled by:

```text
TransferPairingUseCase
```

A transfer should only be finalized after a valid debit/credit pair is found.

Current conceptual flow:

```text
Debit
  ↓
pending_transactions

Credit
  ↓
pending_transactions

Pairing
  ↓
Debit + Credit
  ↓
Save Transfer
  ↓
Update Wallets
```

Do NOT assume every debit and credit with the same amount belongs to the same transfer.

Always preserve the existing pairing rules unless explicitly asked to modify them.

---

# 12. FinalizePendingUseCase

File:

```text
lib/domain/usecases/transaction/finalize_pending_usecase.dart
```

Single transactions can be finalized after the configured timeout.

Current timeout:

```text
1 second
```

Important:

Do not silently swallow errors.

If saving a transaction fails, the pending transaction should remain available for retry.

Prefer allowing the error to propagate to the synchronization layer when the caller needs to know that processing failed.

---

# 13. SaveTransactionUseCase

File:

```text
lib/domain/usecases/transaction/save_transaction_usecase.dart
```

Responsibilities:

### Single

```text
insert transaction
        ↓
apply wallet balance
```

### Transfer

```text
insert transfer transaction
        ↓
subtract source wallet
        ↓
add destination wallet
```

Data integrity is critical here.

Avoid a situation where:

```text
transaction inserted
BUT
wallet balance not updated
```

or:

```text
pending deleted
BUT
transaction save failed
```

When modifying this layer, consider using Drift database transactions where appropriate.

---

# 14. TransactionDao

File:

```text
lib/data/dao/transaction_dao.dart
```

Main database:

```text
TransactionsTable
```

Responsibilities:

- insert transaction
- insert transfer
- query transactions
- watch transactions
- get transaction by ID
- delete transaction
- duplicate checking

Transaction IDs must remain unique.

Do not remove duplicate protection.

---

# 15. PendingTransactionDao

File:

```text
lib/data/dao/pending_transaction_dao.dart
```

Responsibilities:

- insert pending transaction
- query pending transactions
- delete pending transactions
- delete multiple pending transactions
- duplicate pending detection

Current duplicate detection uses:

```text
bank
amount
type
rawText
timestamp within 5 seconds
```

Do not change duplicate rules without understanding the notification patterns of supported banks/e-wallets.

---

# 16. Wallet Resolution

Wallet resolution is handled by:

```text
WalletResolverUseCase
```

Current behavior can result in:

```text
wallet == null
```

This is an important business case.

A missing wallet must NOT cause a transaction notification to disappear.

If a wallet does not exist:

```text
notification
      ↓
parsed transaction
      ↓
pending transaction
      ↓
waiting for wallet
```

The exact implementation should be decided before changing the database model.

Do not simply discard the transaction because the wallet is unavailable.

---

# 17. Wallet Balance

File:

```text
ApplyTransactionUseCase
```

Current rules:

### Income

```text
wallet.balance += amount
```

### Expense

```text
wallet.balance -= amount
```

### Transfer

```text
source.balance -= amount
destination.balance += amount
```

Wallet updates must remain consistent with transaction records.

---

# 18. Database Architecture

There are TWO local databases.

## Android Room

Used for notification persistence:

```text
Room
└── notification_logs
```

## Flutter Drift

Used for application/business data:

```text
Drift
├── transactions
├── pending_transactions
├── notification_logs
└── wallets
```

Do not merge or replace these databases without explicit architectural approval.

The Android Room database exists partly because the Android NotificationListenerService needs a persistence mechanism independent of Flutter.

---

# 19. Drift Database

Main file:

```text
lib/data/local/database/app_database.dart
```

Current database:

```text
schemaVersion = 18
```

Migration strategy currently uses:

```text
onCreate → createAll()
onUpgrade → createAll()
```

Be careful when modifying tables.

Do not casually increase schema version or modify migration behavior without checking existing installed databases.

For production-safe migrations, explicitly migrate schema changes instead of relying on destructive recreation.

---

# 20. Application Lifecycle Requirements

This is one of the most important requirements of Auto Finance.

The application must continue capturing notifications when:

```text
Flutter UI is closed
```

and should recover notifications when:

```text
Flutter app is opened again
```

Expected behavior:

```text
Bank sends notification
        ↓
NotificationListenerService
        ↓
Room notification_logs
        ↓
Flutter is unavailable
        ↓
notification remains pending
        ↓
User opens Auto Finance
        ↓
StartupSyncService
        ↓
Transaction processing
        ↓
success
        ↓
Room notification marked processed
```

Do not make notification capture dependent on:

```text
MainActivity
Flutter Engine
EventChannel
Flutter UI
```

---

# 21. Android App Kill Testing

When testing notification capture, distinguish between:

### Case A — Flutter UI closed

Expected:

```text
NotificationListenerService
still receives notification
```

### Case B — App removed from recent apps

Expected behavior depends on Android/OEM lifecycle, but NotificationListenerService should remain independently registered.

### Case C — Force Stop

Android may prevent services from running until the app is launched again.

Do NOT claim force-stop behavior is guaranteed.

### Case D — Device reboot

`BootReceiver` exists to help restore the notification listener state.

Always test on the actual target device.

---

# 22. Android OEM Restrictions

Android manufacturers may apply aggressive background restrictions.

Do not assume behavior from an emulator or one device is universal.

When diagnosing:

```text
NotificationListener not receiving
```

check:

1. Notification Listener permission.
2. Battery optimization.
3. Auto-start/background restrictions.
4. Device-specific restrictions.
5. Android version.
6. Whether the app was force-stopped.
7. Whether the NotificationListenerService is connected.

---

# 23. Error Handling Rules

Never hide errors that affect data integrity.

Bad:

```dart
try {
  await save();
} catch (_) {}
```

Prefer:

```dart
try {
  await save();
} catch (e, stackTrace) {
  log(...);
  rethrow;
}
```

unless the error is intentionally handled.

The synchronization layer must know whether transaction processing succeeded.

---

# 24. Processed Notification Rules

The following rule is critical:

```text
PROCESS SUCCESS
      ↓
mark notification processed
```

NOT:

```text
notification received
      ↓
mark processed
      ↓
try processing
```

If transaction processing fails:

```text
processed = false
```

so it can be retried.

---

# 25. Idempotency

Transaction processing must be safe to retry.

Possible scenario:

```text
Notification received
      ↓
Transaction saved
      ↓
App crashes
      ↓
Notification remains processed=false
      ↓
App starts
      ↓
Notification processed again
```

The system must prevent duplicate transactions.

Always consider:

- notification duplication
- transaction duplication
- pending duplication
- transfer duplication
- wallet balance duplication

before modifying retry behavior.

---

# 26. Atomicity

When a business operation contains multiple database operations, consider whether they must happen atomically.

Example:

```text
save transaction
+
update wallet
```

should ideally behave as one logical operation.

Likewise:

```text
delete pending
+
save transfer
+
update wallets
```

must not leave the application in an inconsistent state.

Use Drift transactions where appropriate.

---

# 27. Logging

Existing debug logs are intentionally verbose during development.

Examples:

```text
🚀 STARTUP SYNC START
===== START SYNC =====
🟢 TRANSACTION ACTION START
🔵 PIPELINE START
🟡 PENDING INSERTED
🟣 FINALIZE START
💾 SAVE SINGLE START
```

Do not remove useful diagnostic logging while debugging lifecycle/data-loss issues.

When adding logs, include:

- notification ID
- transaction ID
- bank
- amount
- processing stage
- success/failure

Avoid logging sensitive financial data in production builds.

---

# 28. Flutter State Management

The project uses:

```text
Riverpod
```

Do not introduce another state management library for a feature unless explicitly requested.

Existing providers should be reused where appropriate.

---

# 29. Coding Style

Use idiomatic Dart and Kotlin.

Dart:

```text
lowerCamelCase
PascalCase for classes
```

Kotlin:

```text
camelCase
PascalCase for classes
```

Prefer clear names over short names.

Avoid unnecessary abstractions.

Do not introduce a repository/service/usecase solely to wrap one trivial method unless it improves architecture.

---

# 30. Before Editing Files

Always identify:

```text
1. Root cause
2. Files involved
3. Current behavior
4. Expected behavior
5. Minimal fix
6. Possible side effects
```

If a change affects database schema:

```text
also identify migration impact
```

If a change affects Android lifecycle:

```text
also inspect:
AndroidManifest
NotificationListenerService
BootReceiver
MainActivity
```

If a change affects transaction processing:

```text
inspect:
TransactionAction
Pipeline
PendingTransactionDao
FinalizePendingUseCase
SaveTransactionUseCase
TransactionDao
ApplyTransactionUseCase
WalletResolverUseCase
```

---

# 31. Before Refactoring

Do not refactor code merely because it looks untidy.

First establish:

```text
Is it broken?
Why is it broken?
What behavior must remain unchanged?
```

Then make the smallest safe change.

---

# 32. Testing Strategy

For notification lifecycle changes, test at least:

### Test 1 — App open

```text
Notification
→ Flutter
→ Transaction
```

### Test 2 — App closed

```text
Notification
→ Room
→ Open app
→ Startup Sync
→ Transaction
```

### Test 3 — App removed from recent apps

```text
Notification
→ Room
→ Open app
→ Transaction
```

### Test 4 — Processing failure

```text
Notification
→ Room
→ processing fails
→ processed remains false
```

### Test 5 — Retry

```text
failed notification
→ app restart
→ retry
→ success
→ processed=true
```

### Test 6 — Duplicate notification

```text
same notification twice
→ only one transaction
```

### Test 7 — Transfer

```text
debit
+
credit
→ one transfer transaction
→ correct wallet balances
```

### Test 8 — Missing wallet

```text
notification
→ wallet unavailable
→ transaction must not disappear
```

### Test 9 — Crash during processing

Simulate failure between:

```text
transaction insert
wallet update
notification processed
```

Verify no inconsistent state is created.

---

# 33. Commands

Before finishing a Dart change, prefer running:

```bash
flutter analyze
```

For tests:

```bash
flutter test
```

For build validation:

```bash
flutter build apk
```

For Android debugging:

```bash
adb logcat
```

Useful filters:

```bash
adb logcat | grep NOTIF
```

and:

```bash
adb logcat | grep DB_TEST
```

Use the project's configured Flutter/FVM version if the repository contains an FVM configuration.

Do not change Flutter/Dart/Gradle/Kotlin versions unless explicitly requested or required to solve a confirmed compatibility issue.

---

# 34. Generated Files

Do not manually edit generated files unless absolutely necessary.

Examples:

```text
*.g.dart
```

For Drift generated files, modify the source table/database definitions and regenerate using the project's configured generation command.

---

# 35. Git Safety

Before making substantial changes:

```bash
git status
```

Do not overwrite unrelated user changes.

Never run destructive commands such as:

```bash
git reset --hard
git clean -fd
```

unless explicitly requested.

Do not discard changes that were already present before Codex started working.

---

# 36. Change Reporting

After modifying code, always report:

```text
Files changed:
- path/to/file1
- path/to/file2

What changed:
- ...
- ...

Why:
- ...

Potential impact:
- ...

Validation:
- flutter analyze
- flutter test
- flutter build apk
```

If a command cannot be executed, explicitly say so.

---

# 37. Important Current Known Issues

These are known areas that require careful investigation.

## Issue 1 — Notification processing and processed state

Current concern:

```text
TransactionAction.handle()
```

can return without necessarily indicating whether processing succeeded.

The synchronization layer currently needs a reliable success/failure signal before calling:

```text
markNotificationProcessed()
```

Do not assume `Future<void>` means processing succeeded.

---

## Issue 2 — Missing wallet

A transaction can currently resolve:

```text
wallet == null
```

For income/expense, the transaction may still be inserted while the wallet balance is not updated.

This behavior needs explicit business handling.

The desired behavior is:

```text
transaction must not disappear
```

If wallet does not exist, it should remain recoverable.

---

## Issue 3 — Transfer null wallet

Transfer code currently uses non-null assertions such as:

```dart
debit.fromWallet!
credit.toWallet!
```

This can crash when wallet resolution fails.

Do not simply replace `!` with `?`.

Determine the correct business behavior first.

---

## Issue 4 — Atomic transaction processing

Current transaction saving and wallet updates may involve multiple database operations.

Investigate whether these should be wrapped in a Drift transaction to prevent:

```text
transaction saved
but wallet update failed
```

or:

```text
pending deleted
but transaction save failed
```

---

## Issue 5 — Retry behavior

A failed notification should remain recoverable.

The system should be idempotent and safe to retry.

---

# 38. Current Priority

The current development priority is:

```text
Priority 1
Reliable notification capture when Flutter is killed.

Priority 2
Reliable startup synchronization.

Priority 3
Correct processed/unprocessed behavior.

Priority 4
Safe transaction processing.

Priority 5
Pending transaction recovery.

Priority 6
Transfer pairing reliability.

Priority 7
Wallet-missing handling.

Priority 8
Atomic database operations.

Priority 9
Testing on real Android devices.
```

Do not optimize UI or perform unrelated refactors while these reliability issues are unresolved.

---

# 39. Golden Rule

The most important rule for Auto Finance:

> NEVER lose a financial notification or silently mark it as processed when the transaction was not successfully handled.

When uncertain, prefer:

```text
keep data pending
```

over:

```text
delete data
```

and prefer:

```text
retry later
```

over:

```text
silently ignore
```

Data integrity is more important than convenience.
