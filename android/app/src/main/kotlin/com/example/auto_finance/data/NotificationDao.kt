// package com.example.auto_finance.data

// import androidx.room.Dao
// import androidx.room.Insert
// import androidx.room.Query

// @Dao
// interface NotificationDao {

//     @Insert
//     fun insert(data: NotificationEntity)

//     @Query("""
//         SELECT * FROM notification_logs
//         ORDER BY timestamp DESC
//     """)
//     fun getAll(): List<NotificationEntity>

//     @Query("""
//         DELETE FROM notification_logs
//     """)
//     fun clear()

//     @Query("""
//         SELECT * FROM notification_logs
//         WHERE processed = 0
//         ORDER BY timestamp ASC
//     """)
//     fun getPending(): List<NotificationEntity>

//     @Query("""
//         UPDATE notification_logs
//         SET processed = 1
//         WHERE id IN (:ids)
//     """)
//     fun markProcessed(ids: List<Long>)
// }

package com.example.auto_finance.data

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import androidx.room.RawQuery
import androidx.sqlite.db.SupportSQLiteQuery

@Dao
interface NotificationDao {

    @Insert
    fun insert(notification: NotificationEntity)

    @Query("""
        SELECT EXISTS(
            SELECT 1 FROM notification_logs
            WHERE packageName = :packageName
              AND title = :title
              AND text = :text
              AND timestamp BETWEEN :fromTimestamp AND :toTimestamp
        )
    """)
    fun hasRecentDuplicate(
        packageName: String,
        title: String,
        text: String,
        fromTimestamp: Long,
        toTimestamp: Long
    ): Boolean

    @Query("""
        UPDATE notification_logs
        SET processed = 0
        WHERE processed = 1
          AND packageName LIKE '%jago%' COLLATE NOCASE
          AND LOWER(title || ' ' || text) LIKE '%menerima%'
    """)
    fun requeueProcessedJagoIncomeNotifications(): Int

    @Query("""
        UPDATE notification_logs
        SET processed = 0
        WHERE processed = 1
          AND packageName LIKE '%jago%' COLLATE NOCASE
          AND LOWER(title || ' ' || text) LIKE '%membayar%'
    """)
    fun requeueProcessedJagoPaymentNotifications(): Int

    @Query("""
        UPDATE notification_logs
        SET processed = 0
        WHERE processed = 1
          AND packageName LIKE '%jago%' COLLATE NOCASE
          AND LOWER(title || ' ' || text) LIKE '%memindahkan%'
          AND LOWER(title || ' ' || text) LIKE '%kantong%'
    """)
    fun requeueProcessedJagoPocketTransfers(): Int

    @Query("""
        UPDATE notification_logs
        SET processed = 0
        WHERE processed = 1
          AND packageName LIKE '%shopee%' COLLATE NOCASE
          AND LOWER(title || ' ' || text) LIKE '%pengisian saldo%'
          AND LOWER(title || ' ' || text) LIKE '%60.000%'
          AND LOWER(title || ' ' || text) LIKE '%shopeepay%'
    """)
    fun requeueProcessedShopeePayTopup60000(): Int

    @Query("""
        UPDATE notification_logs
        SET processed = 0
        WHERE processed = 1
          AND packageName LIKE '%shopee%' COLLATE NOCASE
          AND LOWER(title || ' ' || text) LIKE '%pencairan dana%'
          AND LOWER(title || ' ' || text) LIKE '%menerima%'
    """)
    fun requeueProcessedShopeePayCashOutReceived(): Int

    @Query("""
        UPDATE notification_logs
        SET processed = 0
        WHERE processed = 1
          AND packageName LIKE '%shopee%' COLLATE NOCASE
          AND LOWER(title || ' ' || text) LIKE '%mengirimkan dana%'
          AND LOWER(title || ' ' || text) LIKE '%ke shopeepay%'
          AND LOWER(title || ' ' || text) LIKE '%bi-fast%'
    """)
    fun requeueProcessedShopeePayBiFastIncoming(): Int

    @Query("""
        SELECT * 
        FROM notification_logs
        WHERE processed = 0
        ORDER BY timestamp ASC
    """)
    fun getPending(): List<NotificationEntity>

    @Query("""
        UPDATE notification_logs
        SET processed = 1
        WHERE id = :id
    """)
    fun markProcessed(id: Long)

    @RawQuery
    fun markUnknownProcessed(query: SupportSQLiteQuery): Int

    @Query("""
        SELECT * 
        FROM notification_logs
        ORDER BY timestamp DESC
    """)
    fun getAll(): List<NotificationEntity>
}
