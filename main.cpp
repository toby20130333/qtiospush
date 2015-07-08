#include <QApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QQmlEngine>
#include <QQmlContext>
#include "qmlmainobject.h"
int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QQmlApplicationEngine engine;
    QQmlContext *rootContext = engine.rootContext();
    QmlMainObject qmlObj(&engine);
    rootContext->setContextProperty("qmlObj",&qmlObj);
    qDebug()<<"mainWindow............ "<<&qmlObj;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    return app.exec();
}
