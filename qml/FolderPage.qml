import QtQuick 2.4
import QtQuick.Controls 2.4
import MeuiKit 1.0 as Meui
import Cyber.FileManager 1.0

Item {
    id: control

    Rectangle {
        anchors.fill: parent
        // anchors.margins: Meui.Units.largeSpacing
        radius: Meui.Theme.bigRadius
        color: Meui.Theme.backgroundColor
    }

    FolderMenu {
        id: folderMenu
    }

    FolderItemMenu {
        id: folderItemMenu
    }

    ExecPromptDialog {
        id: execPromptDialog

        onAccepted: folderModel.runIndex(index)
    }

    Loader {
        id: viewLoader
        anchors.fill: parent

        sourceComponent: {
            if (settings.viewMethod === 0) {
                return folderListView
            } else {
                return folderIconView
            }
        }
    }

    Component {
        id: folderListView

        FolderListView {
            anchors.fill: parent
            model: folderModel

            onRightClicked: {
                folderMenu.popup()
            }

            onItemDoubleClicked: {
                openItem(index)
            }

            onItemPressed: control.forceActiveFocus()
        }
    }

    Component {
        id: folderIconView

        FolderIconView {
            anchors.fill: parent
            model: folderModel

            onRightClicked: {
                folderMenu.popup()
            }

            onItemDoubleClicked: {
                openItem(index)
            }

            onItemPressed: control.forceActiveFocus()
        }
    }

    Label {
        anchors.centerIn: parent
        text: qsTr("No files")
        color: Meui.Theme.disabledTextColor
        font.pixelSize: 25
        visible: folderModel.count === 0
    }

    function openItem(index) {
        var fileIsDir = folderModel.get(index, FolderListModel.FileIsDirRole)
        var isRunnable = folderModel.get(index, FolderListModel.IsRunnableRole)

        console.log(fileIsDir + ", " + isRunnable)

        if (fileIsDir) {
            folderModel.openIndex(index)
            return
        }

        // Run executable binary file.
        if (isRunnable) {
            execPromptDialog.index = index
            execPromptDialog.show()
            return
        }

        // Other mimetype file.
        folderModel.openItem(index)
    }
}