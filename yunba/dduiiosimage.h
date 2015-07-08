#ifndef DDUIIOSIMAGE
#define DDUIIOSIMAGE
#include <QQuickItem>

class IOSImageObject : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(QString imagePath READ imagePath NOTIFY imagePathChanged)

public:
    explicit IOSImageObject(QQuickItem *parent = 0);

    QString imagePath() {
        return m_imagePath;
    }

    QString m_imagePath;

signals:
    void imagePathChanged();

public slots:
    void open();

private:
    void *m_delegate;
};

#endif // DDUIIOSIMAGE

