import QtQuick 2.4
import QtQuick.Controls 2.4
import MeuiKit 1.0 as Meui

Item {
    FolderListView {
        anchors.fill: parent
    }

    Label {
        anchors.centerIn: parent
        text: qsTr("No files")
        color: Meui.Theme.disabledTextColor
        font.pixelSize: 25
        visible: folderModel.count === 0
    }
}
