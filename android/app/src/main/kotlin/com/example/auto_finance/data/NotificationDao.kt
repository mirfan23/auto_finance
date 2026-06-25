// package com.example.auto_finance.data

// import androidx.room.*

// @Dao
// interface NotificationDao {

//     @Insert
//     fun insert(data: NotificationEntity)

//     @Query("SELECT * FROM notification_logs ORDER BY timestamp DESC")
//     fun getAll(): List<NotificationEntity>

//     @Query("DELETE FROM notification_logs")
//     fun clear()

//     @Query("""
//     SELECT * FROM notification_logs
//     WHERE processed = 0
//     ORDER BY timestamp ASC
//     """)
//     fun getPending(): List<NotificationEntity>


//     @Query("""
//     UPDATE notification_logs
//     SET processed = 1
//     WHERE id IN (:ids)
//     """)
//     fun markProcessed(ids: List<Long>)
// }

package com.example.auto_finance.data

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query

@Dao
interface NotificationDao {

    @Insert
    fun insert(data: NotificationEntity)

    @Query("""
        SELECT * FROM notification_logs
        ORDER BY timestamp DESC
    """)
    fun getAll(): List<NotificationEntity>

    @Query("""
        DELETE FROM notification_logs
    """)
    fun clear()

    @Query("""
        SELECT * FROM notification_logs
        WHERE processed = 0
        ORDER BY timestamp ASC
    """)
    fun getPending(): List<NotificationEntity>

    @Query("""
        UPDATE notification_logs
        SET processed = 1
        WHERE id IN (:ids)
    """)
    fun markProcessed(ids: List<Long>)
}