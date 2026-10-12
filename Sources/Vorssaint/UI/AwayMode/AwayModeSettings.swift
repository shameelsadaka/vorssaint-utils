// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import SwiftUI

struct AwayModeSettings: View {
    @ObservedObject private var l10n = L10n.shared
    @ObservedObject private var manager = CleaningModeManager.shared
    @AppStorage(DefaultsKey.awayModeShowAgents) private var showAgents = true
    @AppStorage(DefaultsKey.awayModeKeepAwake) private var keepAwake = true
    @AppStorage(DefaultsKey.panelUtilityAwayMode) private var showInMenu = true
    @AppStorage(DefaultsKey.notchHiddenControls) private var hiddenControls = NotchControlItem.defaultHidden
    @AppStorage(DefaultsKey.awayModeShortcutEnabled) private var shortcutEnabled = false

    var body: some View {
        let strings = AwayModeStrings.get(l10n.language)
        let controls = AwayModeStrings.controls(l10n.language)
        Section {
            Button {
                manager.activate(mode: .away)
            } label: {
                Label(strings.start, systemImage: AppFeature.awayMode.symbolName)
            }
            Text(strings.description).font(.caption).foregroundStyle(.secondary)
            Toggle(controls.menu, isOn: $showInMenu)
            Toggle(controls.island, isOn: islandVisibility)
            Toggle(l10n.s.quickToolShortcutToggle, isOn: $shortcutEnabled)
                .onChange(of: shortcutEnabled) { _, _ in manager.syncAwayPreferences() }
            ShortcutPreferenceRow(role: .awayMode, isEnabled: shortcutEnabled) {
                manager.syncAwayPreferences()
            }
            if shortcutEnabled, manager.shortcutRegistrationFailed {
                Text(l10n.s.shortcutUnavailable).font(.caption).foregroundStyle(.orange)
            }
            Toggle(strings.showAgents, isOn: $showAgents)
            Text(strings.agentsHint).font(.caption).foregroundStyle(.secondary)
            Toggle(strings.keepAwake, isOn: $keepAwake)
            Text(strings.unlockHint).font(.caption).foregroundStyle(.secondary)
            Text(strings.notice).font(.caption).foregroundStyle(.secondary)
        } header: {
            Text(strings.title)
        }
    }

    /// Use the Island editor's existing visibility key, not a second setting.
    private var islandVisibility: Binding<Bool> {
        Binding {
            !hiddenControls.split(separator: ",").contains(Substring(NotchControlItem.awayMode.rawValue))
        } set: { shown in
            var hidden = Set(hiddenControls.split(separator: ",").map(String.init))
            if shown { hidden.remove(NotchControlItem.awayMode.rawValue) }
            else { hidden.insert(NotchControlItem.awayMode.rawValue) }
            hiddenControls = hidden.sorted().joined(separator: ",")
            if AppFeature.notch.isAvailable { NotchService.shared.syncWithPreferences() }
        }
    }
}
