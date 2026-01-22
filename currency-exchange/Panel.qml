import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services.UI
import qs.Widgets
import "CurrencyData.js" as CurrencyData

Item {
  id: root

  property var pluginApi: null

  readonly property var geometryPlaceholder: panelContainer
  property real contentPreferredWidth: 420 * Style.uiScaleRatio
  property real contentPreferredHeight: 280 * Style.uiScaleRatio
  readonly property bool allowAttach: true

  anchors.fill: parent

  readonly property var main: pluginApi?.mainInstance

  property var cfg: pluginApi?.pluginSettings || ({})
  property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

  property string fromCurrency: cfg.sourceCurrency || defaults.sourceCurrency
  property string toCurrency: cfg.targetCurrency || defaults.targetCurrency
  property real fromAmount: 1.0

  readonly property bool loading: main?.loading || false
  readonly property bool loaded: main?.loaded || false
  readonly property real toAmount: main ? main.convert(fromAmount, fromCurrency, toCurrency) : 0
  readonly property real rate: main ? main.getRate(fromCurrency, toCurrency) : 0

  property var currencyModel: CurrencyData.buildCompactModel()

  function swapCurrencies() {
    var temp = fromCurrency;
    fromCurrency = toCurrency;
    toCurrency = temp;
    saveSelectedCurrencies();
  }

  function saveSelectedCurrencies() {
    if (pluginApi && pluginApi.pluginSettings) {
      pluginApi.pluginSettings.sourceCurrency = fromCurrency;
      pluginApi.pluginSettings.targetCurrency = toCurrency;
      pluginApi.saveSettings();
    }
  }

  Rectangle {
    id: panelContainer
    anchors.fill: parent
    color: "transparent"

    ColumnLayout {
      id: mainColumn
      anchors.fill: parent
      anchors.margins: Style.marginL
      spacing: Style.marginM

      // HEADER
      NBox {
        Layout.fillWidth: true
        implicitHeight: headerRow.implicitHeight + (Style.marginXL)

        RowLayout {
          id: headerRow
          anchors.fill: parent
          anchors.margins: Style.marginM
          spacing: Style.marginM

          NIcon {
            icon: "currency-dollar"
            pointSize: Style.fontSizeXXL
            color: Color.mPrimary
          }

          NText {
            text: "Currency Converter"
            pointSize: Style.fontSizeL
            font.weight: Style.fontWeightBold
            color: Color.mOnSurface
            Layout.fillWidth: true
          }

          NIconButton {
            icon: "refresh"
            tooltipText: "Refresh rates"
            baseSize: Style.baseWidgetSize * 0.8
            onClicked: {
              if (main) main.fetchRates(true);
            }
          }

          NIconButton {
            icon: "close"
            tooltipText: "Close"
            baseSize: Style.baseWidgetSize * 0.8
            onClicked: {
              if (pluginApi) pluginApi.withCurrentScreen((s) => pluginApi.closePanel(s))
            }
          }
        }
      }

    }
  }

  Component.onCompleted: {
    if (main) {
      main.fetchRates();
    }
  }
}
