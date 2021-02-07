import QtQuick 2.12
import QtQuick.Controls 2.12
import Cyber.FileManager 1.0

Menu {
    id: control
    implicitWidth: 200

    property var item : ({})
    property int index : -1
    property bool isDir : false
    property bool isExec : false

    signal openClicked(var item)
    signal removeClicked(var item)
    signal copyClicked(var item)
    signal cutClicked(var item)
    signal renameClicked(var item)

    MenuItem {
        text: qsTr("Open")
        onTriggered: {
            openClicked(control.item)
            close()
        }
    }

    MenuItem {
        text: qsTr("Copy")
        onTriggered: {
            copyClicked(control.item)
            close()
        }
    }

    MenuItem {
        text: qsTr("Cut")
        onTriggered: {
            cutClicked(control.item)
            close()
        }
    }

    MenuItem {
        text: qsTr("Rename")
        onTriggered: {
            renameClicked(control.item)
            close()
        }
    }

    MenuItem {
        text: qsTr("Remove")
        onTriggered: {
            removeClicked(control.item)
            close()
        }
    }

    function show(index) {
        control.item = currentFMModel.get(index)

        if (item) {
            control.index = index
            control.isDir = item.isdir === true || item.isdir === "true"
            control.isExec = item.executable === true || item.executable === "true"
            popup()
        }

    }
}
