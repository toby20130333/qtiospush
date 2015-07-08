import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.2

import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2

ApplicationWindow {
    width: 640
    height: 480
    visible: true
    Label{
        id:lb
        width: parent.width
        font.pixelSize: 16
        height: 20
        text: "云巴推送接入示例 联系312125701群"
        horizontalAlignment: Text.AlignHCenter
    }

    //显示消息状态
    TextArea {
        id:tips
        width: parent.width
        anchors.top: lb.bottom
        font.pixelSize: 18
        height: 100
    }
    //画出连接云巴服务的按钮
    Button{
        id:connectBtn
        enabled:false
        anchors.bottom:  parent.bottom
        anchors.bottomMargin:10
        anchors.horizontalCenter: parent.horizontalCenter
        width:200
        height:30
        style: ButtonStyle {
            background: Rectangle {
                implicitWidth: 100
                implicitHeight: 30
                border.width: control.activeFocus ? 2 : 1
                border.color: "#888"
                radius: 1
                gradient: Gradient {
                    GradientStop { position: 0 ; color: control.pressed ? "#ccc" : "#eee" }
                    GradientStop { position: 1 ; color: control.pressed ? "#aaa" : "#ccc" }
                }
                Text{
                    id:txt
                    text: "1.连接云巴服务器"
                    font.family: "Helvetica"
                    font.pointSize: 20
                    color: "black"
                    width: parent.width
                    height: parent.height
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        onClicked: {
            setStauts("正在连接云巴服务器...");
            qmlObj.compentFinished();
        }
    }
    //输入topic
    Rectangle{
        id:topicTxt
        width: 200
        height: 30
        anchors.bottom:  connectBtn.top
        anchors.bottomMargin:10
        border.width: 2
        border.color: "gray"
        anchors.horizontalCenter: parent.horizontalCenter
        Row{
            anchors.fill: parent
            anchors.margins: 2
            Text {
                id: topic
                text: qsTr("订阅频道:")
            }
            TextInput {
                id:topicTxt2
                text: "System2";//需要在云巴后端设置这样一个topic

                font.weight: Font.DemiBold
            }
        }
    }
    //订阅topic
    Button{
        id:subBtn
        enabled:false
        anchors.bottom:  topicTxt.top
        anchors.bottomMargin:10
        anchors.horizontalCenter: parent.horizontalCenter
        width:200
        height:40
        style: ButtonStyle {
            background: Rectangle {
                implicitWidth: 200
                implicitHeight: 30
                border.width: control.activeFocus ? 2 : 1
                border.color: "#888"
                radius: 1
                gradient: Gradient {
                    GradientStop { position: 0 ; color: control.pressed ? "#ccc" : "#eee" }
                    GradientStop { position: 1 ; color: control.pressed ? "#aaa" : "#ccc" }
                }
                Text{
                    id:txt2
                    text: "2.订阅该主题"
                    font.family: "Helvetica"
                    font.pointSize: 24
                    color: "black"
                    width: parent.width
                    height: parent.height
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        onClicked: {
            setStauts("正在订阅主题...");
            qmlObj.setTopicTitle(topicTxt2.text);
        }
    }

    //发送消息
    Button{
        id:sendBtn
        enabled:true
        anchors.bottom:  subBtn.top
        anchors.bottomMargin:10
        anchors.horizontalCenter: parent.horizontalCenter
        width:200
        height:40
        style: ButtonStyle {
            background: Rectangle {
                implicitWidth: 200
                implicitHeight: 30
                border.width: control.activeFocus ? 2 : 1
                border.color: "#888"
                radius: 1
                gradient: Gradient {
                    GradientStop { position: 0 ; color: control.pressed ? "#ccc" : "#eee" }
                    GradientStop { position: 1 ; color: control.pressed ? "#aaa" : "#ccc" }
                }
                Text{
                    id:txt3
                    text: "3.发送消息"
                    font.family: "Helvetica"
                    font.pointSize: 24
                    color: "black"
                    width: parent.width
                    height: parent.height
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        onClicked: {

            if(edit.text !=""){
                setStauts("正在发送消息"+edit.text);
                qmlObj.publishMsg(topicTxt2.text,edit.text);
            }else{
                setStauts("正在发送空消息,请注意...");
            }
        }
    }
    //写入消息框
    Rectangle{
        width: parent.width;
        height: 200;
        anchors.top: tips.bottom
        anchors.topMargin: 10
        border.color: "gray"
        border.width: 2
        Flickable {
            id: flick
            anchors.fill: parent
            anchors.margins: 2
            contentWidth: edit.paintedWidth
            contentHeight: edit.paintedHeight
            clip: true
            boundsBehavior:Flickable.StopAtBounds
            function ensureVisible(r)
            {
                if (contentX >= r.x)
                    contentX = r.x;
                else if (contentX+width <= r.x+r.width)
                    contentX = r.x+r.width-width;
                if (contentY >= r.y)
                    contentY = r.y;
                else if (contentY+height <= r.y+r.height)
                    contentY = r.y+r.height-height;
            }

            TextEdit {
                id: edit
                width: flick.width
                height: flick.height
                wrapMode: TextEdit.Wrap
                onCursorRectangleChanged: flick.ensureVisible(cursorRectangle)
            }
        }
    }

    function setStauts(txt){
        tips.append(txt);
    }
    Component.onCompleted: {
        setStauts("UI加载完成,请点击连接服务器...");
        connectBtn.enabled = true;
    }
    Connections{
        target: qmlObj
        onRecieveMsgFromYunba:{
            console.log("fffffffffffffffffmsg========== "+msg);
            setStauts(msg);
        }
        onSignalUIdelegateStatus:{
            console.log("onSignalUIdelegateStatus========== "+iType);
            setStauts(iType)
        }
        onEmitConnectYunbaServer:{
            console.log("onEmitConnectYunbaServer========== "+success);
            subBtn.enabled = success;
            setStauts((success?"连接服务器成功,请订阅频道":"连接服务器失败"))
        }
        onSignalSendMsg:{
            console.log("onSignalSendMsg========== "+success);
            edit.text ="";
            setStauts((success?"发送成功":"发送失败"))
        }
        onSignalSubTopic:{
            console.log("onSignalSubTopic========== "+success);
            setStauts((success?"订阅成功":"订阅失败"))
        }
    }
}
