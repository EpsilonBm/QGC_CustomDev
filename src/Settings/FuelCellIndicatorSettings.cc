#include "FuelCellIndicatorSettings.h"

#include <QSettings>
#include <QtQml/QQmlEngine>

DECLARE_SETTINGGROUP(FuelCellIndicator, "FuelCellIndicator")
{
    qmlRegisterUncreatableType<FuelCellIndicatorSettings>("QGroundControl.SettingsManager", 1, 0, "FuelCellIndicatorSettings", "Reference only"); \
}

DECLARE_SETTINGSFACT(FuelCellIndicatorSettings, PercentageDisplay)
DECLARE_SETTINGSFACT(FuelCellIndicatorSettings, VoltageDisplay)
DECLARE_SETTINGSFACT(FuelCellIndicatorSettings, RemainingTimeDisplay)
DECLARE_SETTINGSFACT(FuelCellIndicatorSettings, RuntimeCommand)
DECLARE_SETTINGSFACT(FuelCellIndicatorSettings, RequestedPower)
DECLARE_SETTINGSFACT(FuelCellIndicatorSettings, StartupMode)
