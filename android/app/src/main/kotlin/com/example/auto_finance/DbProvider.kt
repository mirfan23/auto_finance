package com.example.auto_finance

import android.content.Context
import androidx.room.Room
import com.example.auto_finance.data.AppDatabase

object DbProvider {

    private var instance: AppDatabase? = null

    fun get(context: Context): AppDatabase {
        if (instance == null) {
            instance = Room.databaseBuilder(
                context.applicationContext,
                AppDatabase::class.java,
                "auto_finance.db"
            ).build()
        }
        return instance!!
    }
}