#-------------------------------------------------
#
# Project created by QtCreator 2014-12-03T13:04:24
#
#
#-------------------------------------------------

QT += qml quick widgets

INCLUDEPATH +=$$PWD

ICON_DATA.files = \
        $$PWD/ios/Icon.png \
        $$PWD/ios/Icon@2x.png \
        $$PWD/ios/Icon-60.png \
        $$PWD/ios/Icon-60@2x.png \
        $$PWD/ios/Icon-72.png \
        $$PWD/ios/Icon-72@2x.png \
        $$PWD/ios/Icon-76.png \
        $$PWD/ios/Icon-76@2x.png \
        $$PWD/ios/Def.png \
        $$PWD/ios/Def@2x.png \
        $$PWD/ios/Def-Portrait.png \
        $$PWD/ios/Def-568h@2x.png
        QMAKE_BUNDLE_DATA += ICON_DATA
        QMAKE_INFO_PLIST = $$PWD/ios/Project-Info.plist
        OTHER_FILES += $$QMAKE_INFO_PLIST

SOURCES += $$PWD/qmlmainobject.cpp \
                $$PWD/main.cpp
HEADERS += \
    $$PWD/yunba/YunBaService.h \
    $$PWD/qmlmainobject.h \
    $$PWD/yunba/dduiiosimage.h

OBJECTIVE_SOURCES += \
    $$PWD/yunba/dduiiosnotification.mm \
    $$PWD/yunba/dduiiosimage.mm
    QMAKE_LFLAGS    += -framework OpenGLES
    QMAKE_LFLAGS    += -framework GLKit
    QMAKE_LFLAGS    += -framework CFNetwork
    QMAKE_LFLAGS    += -framework QuartzCore
    QMAKE_LFLAGS    += -framework CoreVideo
    QMAKE_LFLAGS    += -framework CoreAudio
    QMAKE_LFLAGS    += -framework CoreImage
    QMAKE_LFLAGS    += -framework CoreMedia
    QMAKE_LFLAGS    += -framework AVFoundation
    QMAKE_LFLAGS    += -framework AudioToolbox
    QMAKE_LFLAGS    += -framework CoreGraphics
    QMAKE_LFLAGS    += -framework UIKit
    QMAKE_LFLAGS    += -framework Security
    QMAKE_LFLAGS    += -framework SystemConfiguration
    QMAKE_LFLAGS    += -framework AssetsLibrary
LIBS += -L$$PWD/yunba/ -lYunBa

INCLUDEPATH += $$PWD/yunba
DEPENDPATH += $$PWD/yunba

PRE_TARGETDEPS += $$PWD/yunba/libYunBa.a
OTHER_FILES += $$PWD/main.qml

RESOURCES += \
    demorc.qrc
