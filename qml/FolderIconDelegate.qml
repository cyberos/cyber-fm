import QtQuick 2.4
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import MeuiKit 1.0 as Meui

Item {
    id: control

    property var label
    property var iconSource
    property var imageSource

    property bool isCurrentItem : GridView.isCurrentItem

    property color hoveredColor: Qt.rgba(Meui.Theme.textColor.r,
                                         Meui.Theme.textColor.g,
                                         Meui.Theme.textColor.b,
                                         0.1)

    signal clicked(var index)
    signal rightClicked(var index)
    signal doubleClicked(var index)
    signal contentDropped(var drop)

    Drag.active: mouseArea.drag.active
    Drag.dragType: Drag.Automatic
    Drag.supportedActions: Qt.MoveAction
    Drag.keys: ["text/uri-list"]
    Drag.mimeData: { "text/uri-list": model.path }
    Drag.hotSpot.x: control.width / 2
    Drag.hotSpot.y: control.height / 2

    DropArea {
        id: _dropArea
        anchors.fill: parent
        enabled: model.isdir
        onDropped: control.contentDropped(drop)
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        anchors.margins: Meui.Units.largeSpacing
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        drag.axis: Drag.XAndYAxis
        hoverEnabled: true

        onClicked: {
            if (mouse.button === Qt.LeftButton)
                control.clicked(index)
            else if (mouse.button === Qt.RightButton)
                control.rightClicked(index)
        }

        onDoubleClicked: control.doubleClicked(index)

        onPressed: {
            if (mouse.source !== Qt.MouseEventSynthesizedByQt) {
                drag.target = mouseArea
                control.grabToImage(function(result) {
                    control.Drag.imageSource = result.url
                })
            }
        }

        onReleased: drag.target = null
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Meui.Units.largeSpacing

        Item {
            id: iconItem
            Layout.preferredHeight: parent.height * 0.6
            Layout.leftMargin: Meui.Units.largeSpacing
            Layout.rightMargin: Meui.Units.largeSpacing
            Layout.fillWidth: true

            Image {
                id: icon
                anchors.centerIn: parent
                width: parent.height
                height: width
                sourceSize: Qt.size(width, height)
                source: "image://icontheme/" + control.iconSource
                visible: !image.visible
                asynchronous: true
            }

            Image {
                id: image
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                visible: status === Image.Ready
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                sourceSize.width: width
                sourceSize.height: height
                source: control.imageSource
                asynchronous: true
                cache: true

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Item {
                        width: image.width
                        height: image.height

                        Rectangle {
                            anchors.centerIn: parent
                            width: Math.min(parent.width, image.paintedWidth)
                            height: Math.min(parent.height, image.paintedHeight)
                            radius: Meui.Theme.smallRadius
                        }
                    }
                }
            }

            Rectangle {
                anchors.centerIn: parent
                width: image.status === Image.Ready ? Math.min(parent.width, image.paintedWidth) : parent.width
                height: image.status === Image.Ready ? Math.min(parent.height, image.paintedHeight) : parent.height
                border.color: isCurrentItem ? Meui.Theme.highlightColor : Qt.darker(Meui.Theme.backgroundColor, 2.15)
                border.width: isCurrentItem ? 2 : 1
                radius: Meui.Theme.smallRadius
                color: "transparent"
                opacity: 0.8
                visible: image.visible

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    anchors.margins: 1
                    radius: parent.radius - 0.5
                    border.color: Qt.lighter(Meui.Theme.backgroundColor, 2)
                    opacity: 0.3
                }

            }
        }

        Item {
            id: textItem
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(_label.implicitHeight, height)

            Rectangle {
                width: Math.min(_label.implicitWidth + Meui.Units.largeSpacing, parent.width)
                height: Math.min(_label.implicitHeight + Meui.Units.largeSpacing, parent.height)
                anchors.centerIn: parent
                color: isCurrentItem ? Meui.Theme.highlightColor :
                    mouseArea.containsMouse ? Meui.Theme.secondBackgroundColor : "transparent"
                Behavior on color {
                    ColorAnimation { duration: 125 }
                }
                radius: Meui.Theme.smallRadius
            }

            Label {
                id: _label
                anchors.fill: parent
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                elide: Qt.ElideRight
                wrapMode: Text.Wrap
                color: isCurrentItem ? Meui.Theme.highlightedTextColor : Meui.Theme.textColor
                text: label
            }
        }
    }
}
