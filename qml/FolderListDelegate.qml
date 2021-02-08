import QtQuick 2.4
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import Cyber.FileManager 1.0
import MeuiKit 1.0 as Meui

Item {
    id: control
    width: ListView.view.width - Meui.Units.largeSpacing * 2
    height: 48

    property var label1
    property var label2
    property var iconSource
    property var imageSource

    property bool isSelected: ListView.isCurrentItem

    property color hoverColor: Qt.rgba(Meui.Theme.textColor.r,
                                       Meui.Theme.textColor.g,
                                       Meui.Theme.textColor.b, 0.1)

    signal clicked(var index)
    signal rightClicked(var index)
    signal doubleClicked(var index)
    signal contentDropped(var drop)

    Drag.active: _mouseArea.drag.active
    Drag.dragType: Drag.Automatic
    Drag.supportedActions: Qt.MoveAction
    Drag.keys: ["text/uri-list"]
    Drag.mimeData: { "text/uri-list": model.path }

    Rectangle {
        z: -1
        anchors.fill: parent
        radius: Meui.Theme.bigRadius
        color: isSelected ? Meui.Theme.highlightColor : control.hoverColor
        visible: isSelected || _mouseArea.containsMouse
    }

    DropArea {
        id: _dropArea
        anchors.fill: parent
        enabled: model.isdir
        onDropped: control.contentDropped(drop)
    }

    MouseArea {
        id: _mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        drag.axis: Drag.XAndYAxis

        onClicked: {
            if (mouse.button === Qt.LeftButton)
                control.clicked(index)
            else if (mouse.button === Qt.RightButton)
                control.rightClicked(index)
        }

        onDoubleClicked: control.doubleClicked(index)

        onPressed: {
            if (mouse.source !== Qt.MouseEventSynthesizedByQt) {
                drag.target = _mouseArea
                control.grabToImage(function(result) {
                    control.Drag.imageSource = result.url
                })
            }
        }

        onReleased: drag.target = null
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Meui.Units.largeSpacing
        anchors.rightMargin: Meui.Units.largeSpacing
        spacing: Meui.Units.largeSpacing

        Item {
            id: iconItem
            Layout.fillHeight: true
            width: parent.height * 0.8

            Image {
                id: icon
                anchors.centerIn: iconItem
                width: iconItem.width
                height: width
                sourceSize.width: width
                sourceSize.height: height
                source: "image://icontheme/" + control.iconSource
                visible: !image.visible
                asynchronous: true

            }

            Image {
                id: image
                width: parent.height * 0.8
                height: width
                anchors.centerIn: iconItem
                sourceSize: Qt.size(icon.width, icon.height)
                source: control.imageSource
                visible: image.status == Image.Ready
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: false

            }
        }

        Label {
            text: label1
            Layout.fillWidth: true
            color: isSelected ? Meui.Theme.highlightedTextColor : Meui.Theme.textColor
        }

        Label {
            text: label2
            color: isSelected ? Meui.Theme.highlightedTextColor : Meui.Theme.textColor
        }
    }
}
