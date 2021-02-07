import QtQuick 2.4
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import MeuiKit 1.0 as Meui

Item {
    id: item
    width: parent ? parent.width : undefined
    implicitHeight: 48

    property bool checked: false
    property var iconName
    property var text
    signal clicked

    Rectangle {
        id: rect
        anchors.fill: parent
        radius: Meui.Theme.bigRadius
        color: item.checked ? Meui.Theme.highlightColor
                           : mouseArea.containsMouse ? Qt.rgba(Meui.Theme.textColor.r,
                                                               Meui.Theme.textColor.g,
                                                               Meui.Theme.textColor.b, 0.1) : "transparent"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        onClicked: item.clicked()
    }

    RowLayout {
        anchors.fill: rect
        anchors.leftMargin: Meui.Units.largeSpacing
        anchors.rightMargin: Meui.Units.largeSpacing

        spacing: Meui.Units.largeSpacing

        Image {
            id: image
            height: parent.height * 0.4
            width: height
            source: item.iconName
            sourceSize: Qt.size(width, height)
            Layout.alignment: Qt.AlignVCenter

//            ColorOverlay {
//                anchors.fill: image
//                source: image
//                color: itemTitle.color
//            }
        }

        Label {
            id: itemTitle
            text: item.text
            color: item.checked ? Meui.Theme.highlightedTextColor : Meui.Theme.textColor
            elide: Text.ElideRight

            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
        }
    }
}
