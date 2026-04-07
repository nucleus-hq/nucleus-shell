pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.modules.hosts

Item {
    id: root
    anchors.fill:         parent
    anchors.rightMargin:  Metrics.margin("normal")
    anchors.topMargin:    Metrics.margin("large")
    anchors.bottomMargin: Metrics.margin("large")

    SlotHost {
        id: slots
        moduleId: "sidebarRight"
    }

    ColumnLayout {
        anchors.top:         parent.top
        anchors.left:        parent.left
        anchors.right:       parent.right
        anchors.leftMargin:  Metrics.margin("tiny")
        anchors.rightMargin: Metrics.margin("tiny")
        anchors.margins:     Metrics.margin("large")
        spacing:             Metrics.margin("large")

        // ── Header ────────────────────────────────────────────────────────
        SlotLoader {
            slotId:           "header"
            host:             slots
            Layout.fillWidth: true
        }

        // ── Sliders ───────────────────────────────────────────────────────
        Item {
            Layout.fillWidth:       true
            Layout.preferredHeight: sliderColumn.implicitHeight
            Layout.topMargin: 60

            ColumnLayout {
                id: sliderColumn
                anchors.left:  parent.left
                anchors.right: parent.right
                spacing:       0

                Item {
                    Layout.fillWidth:       true
                    Layout.preferredHeight: 50

                    SlotLoader {
                        anchors.fill: parent
                        slotId:       "volumeSlider"
                        host:         slots
                    }
                }

                Item {
                    Layout.fillWidth:       true
                    Layout.preferredHeight: 50

                    SlotLoader {
                        anchors.fill: parent
                        slotId:       "brightnessSlider"
                        host:         slots
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height:           1
            color:            Appearance.m3colors.m3outlineVariant
        }

        // ── Toggle row 1: network + flight ────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing:          Metrics.spacing(8)

            SlotLoader {
                slotId:                 "networkToggle"
                host:                   slots
                Layout.fillWidth:       true
                Layout.preferredHeight: 80
            }

            SlotLoader {
                slotId:                 "flightModeToggle"
                host:                   slots
                Layout.fillWidth:       true
                Layout.preferredHeight: 80
            }
        }

        // ── Toggle row 2: bluetooth + theme + night ────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing:          Metrics.spacing(8)

            SlotLoader {
                slotId:                 "bluetoothToggle"
                host:                   slots
                Layout.preferredWidth:  220
                Layout.preferredHeight: 80
            }

            SlotLoader {
                slotId:                 "themeToggle"
                host:                   slots
                Layout.fillWidth:       true
                Layout.preferredHeight: 80
            }

            SlotLoader {
                slotId:                 "nightModeToggle"
                host:                   slots
                Layout.fillWidth:       true
                Layout.preferredHeight: 80
            }
        }

        Rectangle {
            Layout.fillWidth:    true
            height:              1
            color:               Appearance.m3colors.m3outlineVariant
            Layout.topMargin:    Metrics.margin(5)
            Layout.bottomMargin: Metrics.margin(5)
        }

        // ── Notifications ─────────────────────────────────────────────────
        SlotLoader {
            slotId:                 "notifModal"
            host:                   slots
            Layout.fillWidth:       true
            Layout.preferredHeight: 450
        }

        // ── Plugin-injected slots (anything not in the list above) ─────────
        Repeater {
            model: slots.slotIds().filter(id => ![
                "header",
                "volumeSlider", "brightnessSlider",
                "networkToggle", "flightModeToggle",
                "bluetoothToggle", "themeToggle", "nightModeToggle",
                "notifModal"
            ].includes(id))

            delegate: SlotLoader {
                required property string modelData
                slotId:           modelData
                host:             slots
                Layout.fillWidth: true
            }
        }
    }
}