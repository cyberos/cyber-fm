import QtQuick 2.12
import QtQuick.Controls 2.12

Menu {
    id: control

    MenuItem {
        text: qsTr("New Folder")
    }

    MenuSeparator {}

    MenuItem {
        text: qsTr("Paste")
        onTriggered: paste()
    }

    function show(parent = control, x, y) {
        popup(parent, x, y)
    }
}
