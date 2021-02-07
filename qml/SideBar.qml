import QtQuick 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.4
import MeuiKit 1.0 as Meui
import Cyber.FileManager 1.0

Item {
    id: control
    implicitWidth: 201

    signal placeClicked(string path)
    signal itemClicked(int index)

    onItemClicked: {
        var item = placesModel.get(index)
        var path = item.path
        placesList.clearBadgeCount(index)
        control.placeClicked(path)
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: placesView
                anchors.fill: parent
                clip: true
                spacing: Meui.Units.largeSpacing

                model: BaseModel {
                    id: placesModel
                    list: PlacesList {
                        id: placesList
                        groups: [
                            FMList.PLACES_PATH,
                            FMList.DRIVES_PATH]
                    }
                }

                ScrollBar.vertical: ScrollBar {}
                flickableDirection: Flickable.VerticalFlick

                delegate: SidebarItem {
                    id: listItem
                    text: model.label
                    iconName: "image://icontheme/" + model.icon
                    onClicked: {
                        placesView.currentIndex = index
                        control.itemClicked(index)
                    }
                }
            }
        }
    }
}
