import QtQuick 2.12
import QtQuick.Controls 2.12
import Cyber.FileManager 1.0

Menu {
    id: control

    property FMList currentList

    signal emptyTrashClicked()

    MenuItem {
        id: newFolderItem
        text: qsTr("New Folder")
        enabled: currentList.pathType !== FMList.TRASH_PATH
    }

    MenuSeparator {
        visible: newFolderItem.visible && pasteItem.visible
    }

    MenuItem {
        id: pasteItem
        text: qsTr("Paste")
        onTriggered: paste()
        enabled: currentList.pathType !== FMList.TRASH_PATH
    }

    MenuItem {
        id: emptyItem
        text: qsTr("Empty Trash")
        visible: currentList.pathType === FMList.TRASH_PATH
        onTriggered: control.emptyTrashClicked()
    }

    function show(parent = control, x, y) {
        popup(parent, x, y)
    }
}
