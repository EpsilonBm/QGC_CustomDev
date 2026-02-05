#include "SpeechManager.h"
#include "Vehicle.h"
#include "AudioOutput.h"
#include "VehicleLinkManager.h"
#include "LinkInterface.h"
#include "LinkConfiguration.h"
#include "QGCLoggingCategory.h"

QGC_LOGGING_CATEGORY(SpeechManagerLog, "qgc.speechmanager")

SpeechManager::SpeechManager(Vehicle* vehicle, QObject* parent)
    : QObject(parent)
    , _vehicle(vehicle)
    , _audioOutput(AudioOutput::instance())
{
    if (_vehicle) {
        _speechTimer = new QTimer(this);
        connect(_speechTimer, &QTimer::timeout, this, &SpeechManager::_playRepeatedSpeech);

        // 监听连接变化
        connect(_vehicle->vehicleLinkManager(), &VehicleLinkManager::primaryLinkChanged,
                this, &SpeechManager::startSpeechPlayback);
    }
}

bool SpeechManager::_isUdpConnection()
{
    if (_vehicle && _vehicle->vehicleLinkManager() &&
        _vehicle->vehicleLinkManager()->primaryLink().lock()) {
        auto link = _vehicle->vehicleLinkManager()->primaryLink().lock();
        auto config = link->linkConfiguration();

        if (config && config->type() == LinkConfiguration::TypeUdp) {
            return true;
        }
    }
    return false;
}

void SpeechManager::_playRepeatedSpeech()
{
    int maxPlays = (_speechDurationSeconds * 1000) / _speechIntervalMs;

    if (_speechCounter < maxPlays) {
        _audioOutput->say(QStringLiteral("宋兄好厉害"));
        _speechCounter++;
        qCDebug(SpeechManagerLog) << "Playing speech, count:" << _speechCounter << "/" << maxPlays;
    } else {
        if (_speechTimer && _speechTimer->isActive()) {
            _speechTimer->stop();
            qCDebug(SpeechManagerLog) << "Stopped repeated speech playback after 10 seconds";
        }
    }
}

void SpeechManager::startSpeechPlayback()
{
    if (_isUdpConnection()) {
        _speechCounter = 0;
        _speechTimer->start(_speechIntervalMs);
        qCDebug(SpeechManagerLog) << "Started repeated speech playback for UDP connection";
    }
}

void SpeechManager::stopSpeechPlayback()
{
    if (_speechTimer && _speechTimer->isActive()) {
        _speechTimer->stop();
        qCDebug(SpeechManagerLog) << "Stopped speech playback";
    }
}
