#include "qmlmainobject.h"
#include <QDebug>
#include <QCoreApplication>
#include <QDateTime>
#include "yunba/dduiiosimage.h"

//设置本地消息到通知栏
QmlMainObject::QmlMainObject(QObject *parent) : QObject(parent)
{
    pushNotifiction("Message: Be overdue", QDateTime::currentDateTime().addSecs(-60)); // 过期的信息不会被显示

    pushNotifiction("Message: Need to cancel", QDateTime::currentDateTime().addSecs(15)); // 被取消的信息不会被显示
    cancelAllNotifictions();
}

QmlMainObject::~QmlMainObject()
{

}
//获取iOS设备的deviceToken
void QmlMainObject::onPushTokenRequestSuccessful(QString deviceToken)
{
    qDebug()<<" onPushTokenRequestSuccessful "<<deviceToken;
}
//获取iOS设备出错
void QmlMainObject::onPushTokenRequestError(QString error)
{
  qDebug()<<" onPushTokenRequestError "<<error;
}

//监听刚刚注册的事件
bool QmlMainObject::event(QEvent* event)
{
    if (event->type() == QEvent::Type(MWRequestPushNotificationRegistrationEvent::MWRequestPushNotificationRegistrationEventType))
    {
        qDebug()<<" MWRequestPushNotificationRegistrationEvent "<<event->type();
        setupPushNotifications();
    }
}

//当UI加载完全或者用户主动(测试)连接云巴服务器
void QmlMainObject::compentFinished()
{
    qDebug()<<" QmlMainObject::compentFinished ";

    qmlRegisterType<IOSImageObject>("IOSImageObject", 1, 0, "IOSImageObject");
    QCoreApplication::postEvent(this, new MWRequestPushNotificationRegistrationEvent(), Qt::HighEventPriority);
}

