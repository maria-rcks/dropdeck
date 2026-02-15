import QtQuick
import "../components" as C

Item {
    id: modalLayer
    property var app

    anchors.fill: parent
    z: 40

    C.ChooserModal {
        visible: app.chooserOpen
        title: app.chooserTitle
        items: app.chooserItems
        powerStyle: app.chooserType === "power"
        scrimColor: app.c("scrim", "#000000aa")
        modalColor: app.c("backgroundElevated", "#060606")
        sectionColor: app.c("backgroundCard", "#101010")
        activeColor: app.s("toggleActiveBg", "#FFFFFF")
        textPrimary: app.c("textPrimary", "#FFFFFF")
        textSecondary: app.c("textSecondary", "#A1A1AA")
        textMuted: app.c("textMuted", "#71717A")
        cardGradientEnabled: app.fx("modalGradientEnabled", false)
        cardGradientOpacity: app.fx("modalGradientOpacity", 0.0)
        cardGradientStart: app.sf("modalGradient", "start", "#ffffff10")
        cardGradientEnd: app.sf("modalGradient", "end", "#00000010")
        onClosed: app.chooserOpen = false
        onSelected: item => app.selectChooserItem(item)
    }

    C.NotificationHistoryModal {
        visible: app.notificationHistoryOpen
        notifications: app.notificationHistory
        scrimColor: app.c("scrim", "#000000aa")
        modalColor: app.c("backgroundElevated", "#060606")
        sectionColor: app.c("backgroundCard", "#101010")
        sectionAltColor: app.s("sliderTrack", "#181818")
        textPrimary: app.c("textPrimary", "#FFFFFF")
        textSecondary: app.c("textSecondary", "#A1A1AA")
        textMuted: app.c("textMuted", "#71717A")
        cardGradientEnabled: app.fx("modalGradientEnabled", false)
        cardGradientOpacity: app.fx("modalGradientOpacity", 0.0)
        cardGradientStart: app.sf("modalGradient", "start", "#ffffff10")
        cardGradientEnd: app.sf("modalGradient", "end", "#00000010")
        onClosed: app.notificationHistoryOpen = false
        onClearAllRequested: {
            const items = app.notificationHistory.slice();
            for (let i = 0; i < items.length; ++i) {
                if (items[i] && items[i].dismiss)
                    items[i].dismiss();
            }
            app.notificationHistory = [];
        }
    }

    C.CalendarModal {
        visible: app.calendarOpen
        scrimColor: app.c("scrim", "#000000aa")
        modalColor: app.c("backgroundElevated", "#060606")
        textPrimary: app.c("textPrimary", "#FFFFFF")
        textSecondary: app.c("textSecondary", "#A1A1AA")
        textMuted: app.c("textMuted", "#6B7280")
        activeDayBg: app.s("toggleActiveBg", "#FFFFFF")
        activeDayFg: app.s("toggleActiveFg", "#000000")
        cardGradientEnabled: app.fx("modalGradientEnabled", false)
        cardGradientOpacity: app.fx("modalGradientOpacity", 0.0)
        cardGradientStart: app.sf("modalGradient", "start", "#ffffff10")
        cardGradientEnd: app.sf("modalGradient", "end", "#00000010")
        onClosed: app.calendarOpen = false
    }

    C.SettingsModal {
        visible: app.settingsModalOpen
        themes: app.availableThemes
        activeTheme: app.activeThemePath
        scrimColor: app.c("scrim", "#000000aa")
        modalColor: app.c("backgroundElevated", "#060606")
        textPrimary: app.c("textPrimary", "#FFFFFF")
        textSecondary: app.c("textSecondary", "#A1A1AA")
        onClosed: app.settingsModalOpen = false
        onRequestTheme: themePath => app.applyTheme(themePath)
    }
}
