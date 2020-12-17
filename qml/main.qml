import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3

import Cyber.FileManager 1.0

import MeuiKit 1.0 as Meui

Window {
    width: 1080
    height: 645
    minimumWidth: 900
    minimumHeight: 600
    visible: true
    title: qsTr("File Manager")

    property alias selection: folderModel.selection

    FolderListModel {
        id: folderModel
    }

    Rectangle {
        anchors.fill: parent
        color: Meui.Theme.backgroundColor
    }

    TextMetrics {
        id: textMetrics
        text: "A"
    }

    ColumnLayout {
        anchors.fill: parent

        Item {
            id: topControls
            Layout.fillWidth: true
            height: textMetrics.height + Meui.Units.largeSpacing * 2

            RowLayout {
                anchors.fill: parent

                PathBar {
                    id: pathBar
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }

        RowLayout {
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
