package com.example.auto_finance

import android.content.Context
import android.content.Intent
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
        views.setTextViewText(
            R.id.widget_budget_amount,
            "${formatRupiah(item.spent)} / ${formatRupiah(item.limit)}",
        )
        val progress = if (item.limit <= 0L) 0 else {
            ((item.spent.toDouble() / item.limit) * 100).toInt().coerceIn(0, 100)
        }
        views.setProgressBar(R.id.widget_budget_item_progress, 100, progress, false)
        return views
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long = position.toLong()

    override fun hasStableIds(): Boolean = true

    private fun formatRupiah(amount: Long): String =
        "Rp ${NumberFormat.getNumberInstance(Locale("id", "ID")).format(amount)}"
}
