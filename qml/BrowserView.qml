import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import MeuiKit 1.0 as Meui
import Cyber.FileManager 1.0

Item {
    id: control

    property FMList currentFMList
    property BaseModel currentFMModel
    property url path: "file:///home/rekols"

    property int currentIndex : -1
    property alias currentView: viewLoader.item

    onPathChanged: {
        control.currentIndex = -1
        control.forceActiveFocus()
    }

    Binding on currentIndex {
        when: control.currentView
        value: control.currentView.currentIndex
    }

    FMList {
        id: _commonFMList
        path: control.path
        foldersFirst: true
        sortBy: FMList.TEXT
    }

    Rectangle {
        anchors.fill: parent
        color: Meui.Theme.backgroundColor
    }

    Loader {
        id: viewLoader
        anchors.fill: parent
        focus: true
        sourceComponent: switch (settings.viewMethod) {
                            case 0: return listViewBrowser
                            case 1: return gridViewBrowser
                         }
        onLoaded: setCurrentFMList()
    }

    Component {
        id: listViewBrowser

        ListView {
            id: _listViewBrowser
            anchors.fill: parent
            clip: true
            ScrollBar.vertical: ScrollBar {}
            currentIndex: control.currentIndex
            spacing: Meui.Units.largeSpacing

            signal areaClicked(var mouse)
            signal areaRightClicked()
            signal keyPress(var event)

            keyNavigationEnabled : true
            keyNavigationWraps : true
            Keys.onPressed: _listViewBrowser.keyPress(event)

            MouseArea {
                anchors.fill: parent
                z: -1
                propagateComposedEvents: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: {
                    _listViewBrowser.areaClicked(mouse)
                    _listViewBrowser.forceActiveFocus()

                    if (mouse.button === Qt.RightButton)
                        _gridViewBrowser.areaRightClicked()
                }
            }

            model: BaseModel {
                id: _browserModel
                list: _commonFMList
                recursiveFilteringEnabled: true
                sortCaseSensitivity: Qt.CaseInsensitive
                filterCaseSensitivity: Qt.CaseInsensitive
            }

            delegate: FolderListDelegate {
                label1: model.label
                label2: model.modified
                iconSource: model.icon
                imageSource: model.thumbnail
            }
        }
    }

    Component {
        id: gridViewBrowser

        GridView {
            id: _gridViewBrowser
            anchors.fill: parent
            clip: true
            ScrollBar.vertical: ScrollBar {}
            currentIndex: control.currentIndex
            cellHeight: Math.floor(96 * 1.5)
            cellWidth: Math.floor(96 * 1.5)

            signal areaClicked(var mouse)
            signal areaRightClicked()
            signal keyPress(var event)

            keyNavigationEnabled : true
            keyNavigationWraps : true
            Keys.onPressed: _gridViewBrowser.keyPress(event)

            MouseArea {
                anchors.fill: parent
                z: -1
                propagateComposedEvents: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: {
                    _gridViewBrowser.areaClicked(mouse)
                    _gridViewBrowser.forceActiveFocus()

                    if (mouse.button === Qt.RightButton)
                        _gridViewBrowser.areaRightClicked()
                }
            }

            property alias currentFMList : _browserModel.list
            property alias currentFMModel : _browserModel

            model: BaseModel {
                id: _browserModel
                list: _commonFMList
                recursiveFilteringEnabled: true
                sortCaseSensitivity: Qt.CaseInsensitive
                filterCaseSensitivity: Qt.CaseInsensitive
            }

            delegate: FolderIconDelegate {
                height: _gridViewBrowser.cellHeight
                width: _gridViewBrowser.cellWidth
                label: model.label
                iconSource: model.icon
                imageSource: model.thumbnail

                onLeftClicked: {
                    control.currentIndex = index
                }

                onRightClicked: {
                    if (control.currentFMList.pathType !== FMList.TRASH_PATH &&
                        control.currentFMList.pathType !== FMList.REMOTE_PATH) {
                        fileMenu.show(index)
                    }
                }

                onDoubleClicked: {
                    openItem(currentIndex)
                }
            }
        }
    }

    BrowserMenu {
        id: browserMenu
    }

    FileMenu {
        id: fileMenu
        modal: true

        onOpenClicked: {
            const path = item.path

            if (item.isdir === "true")
                control.openFolder(path)
            else
                control.openFile(path)
        }

        onCopyClicked: {
            if (item)
                control.copy([item.path])
        }

        onRemoveClicked: {
            if (item)
                control.moveToTrash([item.path])
        }
    }

    Connections {
        enabled: control.currentView
        target: control.currentView
        ignoreUnknownSignals: true

        function onKeyPress(event) {
            const index = control.currentIndex
            const item = control.currentFMModel.get(index)

            console.log(event.key)
        }

        function onAreaRightClicked(mouse) {
            browserMenu.show(control)
        }
    }

    function setCurrentFMList() {
        if (control.currentView) {
            control.currentFMList = currentView.currentFMList
            control.currentFMModel = currentView.currentFMModel
            currentView.forceActiveFocus()
        }
    }

    function openItem(index) {
        const item = control.currentFMModel.get(index)
        const path = item.path

        if (item.isdir === "true")
            control.openFolder(path)
        else
            control.openFile(path)
    }

    function openFile(path) {
        FM.openUrl(path)
    }

    function openFolder(path) {
        if (!String(path).length)
            return;

        control.path = path
    }

    function copy(urls) {
        if (urls.length <= 0)
            return

        Handy.copyToClipboard({"urls": urls}, false)
    }

    function cut(urls) {
        if (urls.length <= 0) {
            return
        }

        Handy.copyToClipboard({"urls": urls}, true)
    }

    function moveToTrash(urls) {
        if (urls.length <= 0)
            return

        FM.moveToTrash(urls)
    }

    function remove(urls) {
        if (urls.length <= 0)
            return

        FM.removeFiles(urls)
    }

    function paste() {
        const data = Handy.getClipboard()
        const urls = data.urls

        if (!urls) {
            return
        }

        if (data.cut) {
            control.currentFMList.cutInto(urls)
        } else {
            control.currentFMList.copyInto(urls)
        }
    }

    function goBack() {
        openFolder(control.currentFMList.previousPath())
    }

    function goForward() {
        openFolder(control.currentFMList.posteriorPath())
    }

    function goUp() {
        openFolder(control.currentFMList.parentPath)
    }

}
