package com.budget.tracker_app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class NetWorthWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->

            val views = RemoteViews(context.packageName, R.layout.net_worth_widget_layout).apply {

                setTextViewText(R.id.net_worth_title, widgetData.getString("netWorthTitle", null)
                ?: "Net Worth")

                setTextViewText(R.id.net_worth_amount, widgetData.getString("netWorthAmount", null)
                ?: "0.00")

                setTextViewText(R.id.net_worth_transactions_number, widgetData.getString("netWorthTransactionsNumber", null)
                ?: "0 transactions")
                
                // Detect App opened via Click inside Flutter
                val pendingIntentWithData = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("launch,${widgetId}"))
                setOnClickPendingIntent(R.id.widget_container, pendingIntentWithData)

            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}