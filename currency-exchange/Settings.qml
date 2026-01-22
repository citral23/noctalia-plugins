import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets
import "CurrencyData.js" as CurrencyData

ColumnLayout {
  id: root
  spacing: Style.marginL

  property var pluginApi: null

  property var cfg: pluginApi?.pluginSettings || ({})
  property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

  // Global currency settings (used by launcher, widget, and panel)
  property string valueSourceCurrency: cfg.sourceCurrency || defaults.sourceCurrency || "USD"
  property string valueTargetCurrency: cfg.targetCurrency || defaults.targetCurrency || "EUR"

  // Widget settings
  property string valueWidgetDisplayMode: cfg.widgetDisplayMode || defaults.widgetDisplayMode || "icon"
  property string valueRefreshInterval: String(cfg.refreshInterval ?? defaults.refreshInterval ?? 60)

  // Refresh interval options (in minutes)
  property var refreshIntervalModel: [
    { "key": "15", "name": "15 minutes" },
    { "key": "30", "name": "30 minutes" },
    { "key": "60", "name": "1 hour" },
    { "key": "180", "name": "3 hours" },
    { "key": "360", "name": "6 hours" },
    { "key": "720", "name": "12 hours" }
  ]

  // Display mode options
  property var displayModeModel: [
    { "key": "icon", "name": "Icon only" },
    { "key": "compact", "name": "Compact (rate number)" },
    { "key": "full", "name": "Full (1 USD = 0.85 EUR)" }
  ]

  // Currency model from shared CurrencyData.js
  property var currencyModel: CurrencyData.buildComboModel(false)

  function saveSettings() {
    if (!pluginApi) return;
    pluginApi.pluginSettings.sourceCurrency = valueSourceCurrency;
    pluginApi.pluginSettings.targetCurrency = valueTargetCurrency;
    pluginApi.pluginSettings.widgetDisplayMode = valueWidgetDisplayMode;
    pluginApi.pluginSettings.refreshInterval = parseInt(valueRefreshInterval);
    pluginApi.saveSettings();
  }

  ColumnLayout {
    Layout.fillWidth: true
    spacing: Style.marginS

    NLabel {
      label: "General Settings"
      Layout.fillWidth: true
      Layout.bottomMargin: Style.marginS
    }

    // TODO: change to searchable combo box
    NComboBox {
      label: "Source Currency"
      description: "Default currency to convert from"
      Layout.fillWidth: true
      minimumWidth: 300
      model: currencyModel
      currentKey: valueSourceCurrency
      onSelected: key => {
        valueSourceCurrency = key;
      }
    }

    // TODO: change to searchable combo box
    NComboBox {
      label: "Target Currency"
      description: "Default currency to convert to"
      Layout.fillWidth: true
      minimumWidth: 300
      model: currencyModel
      currentKey: valueTargetCurrency
      onSelected: key => {
        valueTargetCurrency = key;
      }
    }

  }

  NDivider {
    Layout.fillWidth: true
    Layout.topMargin: Style.marginM
    Layout.bottomMargin: Style.marginM
  }


  ColumnLayout {
    Layout.fillWidth: true
    spacing: Style.marginS

    NLabel {
      label: "Widget Settings"
      // description: "Configure the bar widget appearance and behavior"
      Layout.fillWidth: true
      Layout.bottomMargin: Style.marginS
    }

    NComboBox {
      label: "Display Mode"
      description: "How much information to show in the bar widget"
      Layout.fillWidth: true
      minimumWidth: 250
      model: displayModeModel
      currentKey: valueWidgetDisplayMode
      onSelected: key => {
        valueWidgetDisplayMode = key;
      }
    }

    NComboBox {
      label: "Auto-refresh Interval"
      description: "How often to refresh exchange rates automatically"
      Layout.fillWidth: true
      minimumWidth: 250
      model: refreshIntervalModel
      currentKey: valueRefreshInterval
      onSelected: key => valueRefreshInterval = key
      defaultValue: defaults.refreshInterval
    }
  }

  Item {
    Layout.fillHeight: true
  }
}
