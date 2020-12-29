import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3

import Cyber.FileManager 1.0

import MeuiKit 1.0 as Meui

Meui.Window {
    width: 1080
    height: 645
    minimumWidth: 900
    minimumHeight: 600
    visible: true
    title: qsTr("File Manager")

    hideHeaderOnMaximize: true

    backgroundColor: Meui.Theme.secondBackgroundColor

    property alias selection: folderModel.selection

    FolderListModel {
        id: folderModel
    }

    // Rectangle {
    //     anchors.fill: parent
    //     color: Meui.Theme.backgroundColor
    // }

    TextMetrics {
        id: textMetrics
        text: "A"
    }

    content: ColumnLayout {
        spacing: Meui.Units.largeSpacing

        Item {
            id: topControls
            Layout.fillWidth: true
            height: textMetrics.height + Meui.Units.largeSpacing * 2

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Meui.Units.largeSpacing
                anchors.rightMargin: Meui.Units.largeSpacing
                spacing: Meui.Units.smallSpacing

                IconButton {
                    Layout.fillHeight: true
                    implicitWidth: height
                    source: Meui.Theme.darkMode ? "qrc:/images/dark/go-previous.svg" : "qrc:/images/light/go-previous.svg"
                }

                IconButton {
                    Layout.fillHeight: true
                    implicitWidth: height
                    source: Meui.Theme.darkMode ? "qrc:/images/dark/go-next.svg" : "qrc:/images/light/go-next.svg"
                }

                Item {
                    width: Meui.Units.smallSpacing
                }

                PathBar {
                    id: pathBar
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                Item {
                    width: Meui.Units.smallSpacing
                }

                IconButton {
                    Layout.fillHeight: true
                    implicitWidth: height
                    source: Meui.Theme.darkMode ? "qrc:/images/dark/grid.svg" : "qrc:/images/light/grid.svg"
                }

                IconButton {
                    Layout.fillHeight: true
                    implicitWidth: height
                    source: Meui.Theme.darkMode ? "qrc:/images/dark/list.svg" : "qrc:/images/light/list.svg"
                }
            }
        }

        Item {
            id: bottomControls
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Meui.Units.largeSpacing
                anchors.rightMargin: Meui.Units.largeSpacing
                anchors.bottomMargin: Meui.Units.largeSpacing
                spacing: Meui.Units.largeSpacing

                SideBar {
                    Layout.fillHeight: true
                }

                FolderPage {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }
}
