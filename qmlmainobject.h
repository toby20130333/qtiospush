#ifndef QMLMAINOBJECT_H
#define QMLMAINOBJECT_H

#include <QObject>
#include <QEvent>

class MWRequestPushNotificationRegistrationEvent : public QEvent
{
public:
    MWRequestPushNotificationRegistrationEvent() : QEvent(Type(MWRequestPushNotificationRegistrationEventType))
    {
    }

    enum { MWRequestPushNotificationRegistrationEventType = QEvent::User + 667 };
};
class QmlMainObject : public QObject
{
    Q_OBJECT
public:
    explicit QmlMainObject(QObject *parent = 0);
    ~QmlMainObject();

    void onMenuActivated();
    void setupPushNotifications();
    bool isMainWindowActive();

    void onPushTokenRequestSuccessful(QString);
    void onPushTokenRequestError(QString);
    void cancelAllNotifictions();
    void pushNotifiction(const QString &message, const QDateTime &dateTime);
signals:
    void emitConnectYunbaServer(bool success);
    void recieveMsgFromYunba(const QString& msg);
    void signalUIdelegateStatus(int iType);
    void signalSendMsg(bool success);
    void signalSubTopic(bool success);
protected:
    bool event(QEvent *event);
public slots:
    void compentFinished();
    void setTopicTitle(const QString& topic);
    void publishMsg(const QString& topic,const QString& msg);
};

#endif // QMLMAINOBJECT_H
