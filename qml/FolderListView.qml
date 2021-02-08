import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import MeuiKit 1.0 as Meui
import Cyber.FileManager 1.0

ListView {
    id: control

    property bool enableLassoSelection: true

    signal itemClicked(var index)
    signal itemRightClicked(var index)
    signal itemDoubleClicked(var index)
    signal areaClicked(var mouse)
    signal areaRightClicked()
    signal keyPress(var event)

    keyNavigationEnabled : true
    keyNavigationWraps : true
    Keys.onPressed: control.keyPress(event)

    ScrollBar.vertical: ScrollBar {}
    spacing: Meui.Units.largeSpacing
    topMargin: Meui.Units.smallSpacing
    leftMargin: Meui.Units.largeSpacing
    rightMargin: Meui.Units.largeSpacing
    bottomMargin: Meui.Units.largeSpacing
    clip: true

    Rectangle {
        id: selectLayer
        property int newX: 0
        property int newY: 0

        height: 0
        width: 0
        x: 0
        y: 0
        visible: false
        color: Qt.rgba(control.Meui.Theme.highlightColor.r,
                       control.Meui.Theme.highlightColor.g,
                       control.Meui.Theme.highlightColor.b, 0.2)
        opacity: 0.7

        border.width: 1
        border.color: control.Meui.Theme.highlightColor

        function reset() {
            selectLayer.x = 0;
            selectLayer.y = 0;
            selectLayer.newX = 0;
            selectLayer.newY = 0;
            selectLayer.visible = false;
            selectLayer.width = 0;
            selectLayer.height = 0;
        }
    }

    MouseArea {
        id: mouseArea
        z: -1
        enabled: true
        anchors.fill: parent
        propagateComposedEvents: true
        preventStealing: true
        acceptedButtons: Qt.RightButton | Qt.LeftButton

        onClicked: {
            control.areaClicked(mouse)

            if (mouse.button === Qt.RightButton)
                control.areaRightClicked()
        }

        onPressed: {
            control.forceActiveFocus()

            if (mouse.source === Qt.MouseEventNotSynthesized && mouse.button === Qt.LeftButton) {
                // selection.clear()

                selectLayer.visible = true;
                selectLayer.x = mouseX;
                selectLayer.y = mouseY;
                selectLayer.newX = mouseX;
                selectLayer.newY = mouseY;
                selectLayer.width = 0
                selectLayer.height = 0;
            }
        }

        onPositionChanged: {
            if (mouseArea.pressed && control.enableLassoSelection && selectLayer.visible) {
                if (mouseX >= selectLayer.newX) {
                    selectLayer.width = (mouseX + 10) < (control.x + control.width) ? (mouseX - selectLayer.x) : selectLayer.width;
                } else {
                    selectLayer.x = mouseX < control.x ? control.x : mouseX;
                    selectLayer.width = selectLayer.newX - selectLayer.x;
                }

                if (mouseY >= selectLayer.newY) {
                    selectLayer.height = (mouseY + 10) < (control.y + control.height) ? (mouseY - selectLayer.y) : selectLayer.height;
                    if (!control.atYEnd &&  mouseY > (control.y + control.height))
                         control.contentY += 10
                } else {
                    selectLayer.y = mouseY < control.y ? control.y : mouseY;
                    selectLayer.height = selectLayer.newY - selectLayer.y;

                    if (!control.atYBeginning && selectLayer.y === 0)
                        control.contentY -= 10
                }

                // Select
                var lassoIndexes = []
                var limitY =  mouse.y === selectLayer.y ?  selectLayer.y + selectLayer.height : mouse.y

                for (var y = selectLayer.y; y < limitY; y += 10) {
                    const index = control.indexAt(control.width / 2, y + control.contentY)
                    if (!lassoIndexes.includes(index) && index >- 1 && index < control.count)
                        lassoIndexes.push(index)
                }

                // selection.clear()
                // for (var i = 0; i < lassoIndexes.length; ++i) {
                //     selection.setIndex(lassoIndexes[i], true)
                // }
            }
        }

        onPressAndHold: {
            if (mouse.source !== Qt.MouseEventNotSynthesized && !selectLayer.visible) {
                selectLayer.visible = true;
                selectLayer.x = mouseX;
                selectLayer.y = mouseY;
                selectLayer.newX = mouseX;
                selectLayer.newY = mouseY;
                selectLayer.width = 0
                selectLayer.height = 0;
                mouse.accepted = true
            } else {
                mouse.accepted = false
            }
        }

        onReleased: {
            if (mouse.button !== Qt.LeftButton || !selectLayer.visible) {
                mouse.accepted = false
                return;
            }

            selectLayer.reset()
        }
    }
}
