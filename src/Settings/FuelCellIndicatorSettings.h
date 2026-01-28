#pragma once

#include "SettingsGroup.h"

class FuelCellIndicatorSettings : public SettingsGroup
{
    Q_OBJECT

public:
    FuelCellIndicatorSettings(QObject* parent = nullptr);

    DEFINE_SETTING_NAME_GROUP()

    DEFINE_SETTINGFACT(PercentageDisplay)
    DEFINE_SETTINGFACT(VoltageDisplay)
    DEFINE_SETTINGFACT(RemainingTimeDisplay)
};