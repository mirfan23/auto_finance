package com.example.auto_finance

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import android.widget.RemoteViews
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class FinanceWidgetProvider : AppWidgetProvider() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == ACTION_TOGGLE_VISIBILITY) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit()
                .putBoolean(KEY_HIDDEN, !prefs.getBoolean(KEY_HIDDEN, false))
                .apply()
            updateAll(context)
            return
        }
        super.onReceive(context, intent)
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        Log.i(TAG, "Updating ${appWidgetIds.size} widget instance(s)")
        appWidgetIds.forEach { appWidgetId ->
            try {
                updateWidget(context, appWidgetManager, appWidgetId)
            } catch (error: Exception) {
                Log.e(TAG, "Widget update failed for id=$appWidgetId", error)
            }
        }
    }

    companion object {
        private const val TAG = "FinanceWidgetProvider"
        private const val PREFS_NAME = "auto_finance_widget"
        private const val KEY_TOTAL_BALANCE = "total_balance"
        private const val KEY_MONTHLY_EXPENSE = "monthly_expense"
        private const val KEY_UPDATED_AT = "updated_at"
        private const val KEY_HIDDEN = "hide_widget_amounts"
        private const val ACTION_TOGGLE_VISIBILITY =
            "com.example.auto_finance.action.TOGGLE_WIDGET_VISIBILITY"

        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, FinanceWidgetProvider::class.java)
            val widgetIds = manager.getAppWidgetIds(component)
            Log.i(TAG, "Refreshing ${widgetIds.size} widget instance(s) from app data")
            widgetIds.forEach { appWidgetId ->
                try {
                    updateWidget(context, manager, appWidgetId)
                } catch (error: Exception) {
                    Log.e(TAG, "Widget refresh failed for id=$appWidgetId", error)
                }
            }
        }

        private fun updateWidget(
            context: Context,
            manager: AppWidgetManager,
            appWidgetId: Int,
        ) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val totalBalance = prefs.getLong(KEY_TOTAL_BALANCE, 0L)
            val monthlyExpense = prefs.getLong(KEY_MONTHLY_EXPENSE, 0L)
            val updatedAt = prefs.getLong(KEY_UPDATED_AT, 0L)
            val hideAmounts = prefs.getBoolean(KEY_HIDDEN, false)
            val views = RemoteViews(context.packageName, R.layout.finance_widget)

            val maskedAmount = "••••••"
            views.setTextViewText(
                R.id.widget_total_balance,
                if (hideAmounts) maskedAmount else formatRupiah(totalBalance),
            )
            views.setTextViewText(
                R.id.widget_monthly_expense,
                if (hideAmounts) maskedAmount else formatRupiah(monthlyExpense),
            )
            views.setImageViewResource(
                R.id.widget_toggle_visibility,
                if (hideAmounts) R.drawable.ic_widget_visibility_off
                else R.drawable.ic_widget_visibility,
            )
            views.setContentDescription(
                R.id.widget_toggle_visibility,
                if (hideAmounts) "Tampilkan saldo" else "Sembunyikan saldo",
            )
            val toggleIntent = Intent(context, FinanceWidgetProvider::class.java).apply {
                action = ACTION_TOGGLE_VISIBILITY
                data = Uri.parse("autofinance://widget/visibility/$appWidgetId")
            }
            val togglePendingIntent = PendingIntent.getBroadcast(
                context,
                appWidgetId,
                toggleIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.widget_toggle_visibility, togglePendingIntent)
            val serviceIntent = Intent(context, BudgetWidgetRemoteViewsService::class.java).apply {
                data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME) + "#$appWidgetId")
            }
            views.setRemoteAdapter(R.id.widget_budget_list, serviceIntent)
            views.setEmptyView(R.id.widget_budget_list, R.id.widget_budget_empty)
            views.setTextViewText(
                R.id.widget_updated_at,
                if (updatedAt == 0L) {
                    context.getString(R.string.widget_waiting_for_data)
                } else {
                    val time = SimpleDateFormat("HH:mm", Locale("id", "ID"))
                        .format(Date(updatedAt))
                    context.getString(R.string.widget_updated_at, time)
                },
            )

            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            if (launchIntent != null) {
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    launchIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                )
                views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }

            manager.updateAppWidget(appWidgetId, views)
            manager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_budget_list)
        }

        private fun formatRupiah(amount: Long): String {
            val formatted = java.text.NumberFormat.getNumberInstance(Locale("id", "ID")).format(amount)
            return "Rp $formatted"
        }
    }
}
