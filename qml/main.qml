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

    hideHeaderOnMaximize: false
    headerBarHeight: 40 + Meui.Units.largeSpacing
    backgroundColor: Meui.Theme.secondBackgroundColor

    property alias selection: folderModel.selection
    property QtObject settings: GlobalSettings { }

    FolderListModel {
        id: folderModel
    }

    headerBar: Item {
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Meui.Units.largeSpacing
            anchors.rightMargin: Meui.Units.largeSpacing
            anchors.topMargin: Meui.Units.largeSpacing
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

            PathBar {
                id: pathBar
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            IconButton {
                Layout.fillHeight: true
                implicitWidth: height
                source: Meui.Theme.darkMode ? "qrc:/images/dark/grid.svg" : "qrc:/images/light/grid.svg"
                onClicked: settings.viewMethod = 1
            }

            IconButton {
                Layout.fillHeight: true
                implicitWidth: height
                source: Meui.Theme.darkMode ? "qrc:/images/dark/list.svg" : "qrc:/images/light/list.svg"
                onClicked: settings.viewMethod = 0
            }
        }
    }

    content: ColumnLayout {
        spacing: Meui.Units.largeSpacing

        Item {
            id: bottomControls
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                anchors.fill: parent
                anchors.topMargin: Meui.Units.largeSpacing
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
