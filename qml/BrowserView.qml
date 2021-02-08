import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import MeuiKit 1.0 as Meui
import Cyber.FileManager 1.0

Item {
    id: control

    property FMList currentFMList
    property BaseModel currentFMModel
    property url path: FM.homePath()

    property int currentIndex : -1
    property alias currentView: viewLoader.item

    signal openPathBar

    onPathChanged: {
        control.currentIndex = -1
        control.currentView.forceActiveFocus()
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
        anchors.topMargin: 0
        anchors.leftMargin: Meui.Theme.smallRadius
        anchors.rightMargin: Meui.Theme.smallRadius
        anchors.bottomMargin: Meui.Theme.smallRadius
        radius: Meui.Theme.smallRadius
        color: Meui.Theme.backgroundColor

        Label {
            anchors.centerIn: parent
            text: qsTr("No Files")
            font.pointSize: 20
            visible: currentView && currentView.count === 0
        }
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

        FolderListView {
            id: _listViewBrowser
            anchors.fill: parent
            anchors.bottomMargin: Meui.Units.smallSpacing
            currentIndex: control.currentIndex

            property alias currentFMList : _browserModel.list
            property alias currentFMModel : _browserModel

            model: BaseModel {
                id: _browserModel
                list: _commonFMList
                recursiveFilteringEnabled: true
                sortCaseSensitivity: Qt.CaseInsensitive
                filterCaseSensitivity: Qt.CaseInsensitive
            }

            delegate: FolderListDelegate {
                label1: model.label
                label2: FM.systemFormatDate(model.modified)
                iconSource: model.icon
                imageSource: model.thumbnail
                onClicked: {
                    control.currentIndex = index
                    _listViewBrowser.itemClicked(index)
                }
                onRightClicked: _listViewBrowser.itemRightClicked(index)
                onDoubleClicked: _listViewBrowser.itemDoubleClicked(index)
            }
        }
    }

    Component {
        id: gridViewBrowser

        FolderGridView {
            id: _gridViewBrowser
            anchors.fill: parent
            anchors.topMargin: Meui.Units.smallSpacing
            anchors.leftMargin: Meui.Units.largeSpacing
            anchors.rightMargin: Meui.Units.largeSpacing
            anchors.bottomMargin: Meui.Units.largeSpacing
            currentIndex: control.currentIndex

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

                onClicked: {
                    control.currentIndex = index
                    _gridViewBrowser.itemClicked(index)
                }
                onRightClicked: _gridViewBrowser.itemRightClicked(index)
                onDoubleClicked: _gridViewBrowser.itemDoubleClicked(index)
            }
        }
    }

    BrowserMenu {
        id: browserMenu
        currentList: control.currentFMList
        onEmptyTrashClicked: FM.emptyTrash()
    }

    ItemMenu {
        id: itemMenu
        modal: true

        onOpenClicked: {
            const path = item.path

            if (item.isdir === "true")
                control.openFolder(path)
            else
                control.openFile(path)
        }

        onCutClicked: {
            if (item)
                control.cut([item.path])
        }

        onCopyClicked: {
            if (item)
                control.copy([item.path])
        }

        onRemoveClicked: {
            if (item)
                control.moveToTrash([item.path])
        }

        onWallpaperClicked: {
            if (item)
                Handy.setAsWallpaper(item.path)
        }
    }

    Component.onCompleted: {
        control.currentView.forceActiveFocus()
    }

    Connections {
        enabled: control.currentView
        target: control.currentView
        ignoreUnknownSignals: true

        function onKeyPress(event) {
            const index = control.currentIndex
            const item = control.currentFMModel.get(index)

            if (event.key === Qt.Key_Return)
                control.openItem(index)

            if ((event.key === Qt.Key_V) && (event.modifiers & Qt.ControlModifier))
                control.paste()

            if (event.key === Qt.Key_Backspace)
                control.goUp()

            if (event.key === Qt.Key_L && event.modifiers & Qt.ControlModifier)
                control.openPathBar()
        }

        function onAreaClicked() {
            control.currentView.forceActiveFocus()
        }

        function onAreaRightClicked(mouse) {
            browserMenu.show(control)
        }

        function onItemClicked(index) {
            control.currentView.forceActiveFocus()
        }

        function onItemRightClicked(index) {
            if (control.currentFMList.pathType !== FMList.TRASH_PATH &&
                control.currentFMList.pathType !== FMList.REMOTE_PATH) {
                itemMenu.show(index)
            }

            control.currentView.forceActiveFocus()
        }

        function onItemDoubleClicked(index) {
            control.openItem(index)
        }
    }

    // Function region

    function addToSelection(item) {

    }

    function setCurrentFMList() {
        if (control.currentView) {
            control.currentFMList = currentView.currentFMList
            control.currentFMModel = currentView.currentFMModel
            control.currentView.forceActiveFocus()
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
        control.currentView.forceActiveFocus()
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
