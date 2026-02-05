#pragma once

#include <QObject>
#include <QTimer>
#include <QLoggingCategory>

class AudioOutput;
class Vehicle;

Q_DECLARE_LOGGING_CATEGORY(SpeechManagerLog)

class SpeechManager : public QObject
{
    Q_OBJECT

public:
    explicit SpeechManager(Vehicle* vehicle, QObject* parent = nullptr);
    ~SpeechManager() = default;

    void startSpeechPlayback();
    void stopSpeechPlayback();
    bool _isUdpConnection();

private slots:
    void _playRepeatedSpeech();

private:
    Vehicle* _vehicle = nullptr;
    AudioOutput* _audioOutput = nullptr;
    QTimer* _speechTimer = nullptr;
    int _speechCounter = 0;

    static const int _speechDurationSeconds = 10; // 播放持续时间（秒）
    static const int _speechIntervalMs = 2000;    // 播放间隔（毫秒）
};
