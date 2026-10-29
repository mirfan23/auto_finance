package com.example.auto_finance

import android.content.Context
import android.content.res.ColorStateList
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import org.json.JSONArray
import java.text.NumberFormat
import java.util.Locale

class BudgetWidgetRemoteViewsService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory =
        BudgetViewsFactory(applicationContext)
}

private class BudgetViewsFactory(
    private val context: Context,
) : RemoteViewsService.RemoteViewsFactory {
    private data class BudgetItem(
        val categoryKey: String,
        val category: String,
        val spent: Long,
        val limit: Long,
    )

    private var items: List<BudgetItem> = emptyList()

    override fun onCreate() = onDataSetChanged()

    override fun onDataSetChanged() {
        val raw = context.getSharedPreferences("auto_finance_widget", Context.MODE_PRIVATE)
            .getString("budget_items_json", "[]") ?: "[]"
        items = runCatching {
            val json = JSONArray(raw)
            List(json.length()) { index ->
                val item = json.getJSONObject(index)
                BudgetItem(
                    categoryKey = item.optString("categoryKey", "other"),
                    category = item.optString("category", "Anggaran"),
                    spent = item.optLong("spent", 0L),
                    limit = item.optLong("limit", 0L),
                )
            }
        }.getOrDefault(emptyList())
    }

    override fun onDestroy() {
        items = emptyList()
    }

    override fun getCount(): Int = items.size

    override fun getViewAt(position: Int): RemoteViews? {
        val item = items.getOrNull(position) ?: return null
        val views = RemoteViews(context.packageName, R.layout.finance_widget_budget_item)
        views.setTextViewText(R.id.widget_budget_category, item.category)
        val color = categoryColor(item.categoryKey)
        views.setTextColor(R.id.widget_budget_category, color)
        val hideAmounts = context.getSharedPreferences(
            "auto_finance_widget",
            Context.MODE_PRIVATE,
        ).getBoolean("hide_widget_amounts", false)
        views.setTextViewText(
            R.id.widget_budget_amount,
            if (hideAmounts) "•••••• / ••••••"
            else "${formatRupiah(item.spent)} / ${formatRupiah(item.limit)}",
        )
        val progress = if (hideAmounts || item.limit <= 0L) 0 else {
            ((item.spent.toDouble() / item.limit) * 100).toInt().coerceIn(0, 100)
        }
        views.setProgressBar(R.id.widget_budget_item_progress, 100, progress, false)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            views.setColorStateList(
                R.id.widget_budget_item_progress,
                "setProgressTintList",
                ColorStateList.valueOf(color),
            )
        }
        return views
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long = position.toLong()

    override fun hasStableIds(): Boolean = true

    private fun formatRupiah(amount: Long): String =
        "Rp ${NumberFormat.getNumberInstance(Locale("id", "ID")).format(amount)}"

    private fun categoryColor(category: String): Int = when (category) {
        "food" -> android.graphics.Color.rgb(255, 152, 0)
        "laundry" -> android.graphics.Color.rgb(0, 150, 136)
        "electricity" -> android.graphics.Color.rgb(255, 143, 0)
        "shopping" -> android.graphics.Color.rgb(156, 39, 176)
        "transport" -> android.graphics.Color.rgb(33, 150, 243)
        "bills" -> android.graphics.Color.rgb(244, 67, 54)
        "entertainment" -> android.graphics.Color.rgb(103, 58, 183)
        "health" -> android.graphics.Color.rgb(233, 30, 99)
        "education" -> android.graphics.Color.rgb(63, 81, 181)
        "salary" -> android.graphics.Color.rgb(33, 150, 243)
        "investment" -> android.graphics.Color.rgb(103, 58, 183)
        "topup" -> android.graphics.Color.rgb(0, 188, 212)
        "transfer" -> android.graphics.Color.rgb(96, 125, 139)
        "cashback", "gift" -> android.graphics.Color.rgb(255, 193, 7)
        else -> android.graphics.Color.rgb(158, 158, 158)
    }
}
