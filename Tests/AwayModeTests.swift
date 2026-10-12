// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

enum AwayModeTests {
    static func run(_ suite: TestSuite) {
        var gesture = AwayUnlockGesture()
        gesture.keyDown(code: 53, time: 0, isRepeat: false)
        gesture.keyDown(code: 53, time: 0.1, isRepeat: true)
        gesture.keyDown(code: 53, time: 0.2, isRepeat: true)
        suite.expect(gesture.progress == 1 && !gesture.keyUp(code: 53), "holding Escape never authenticates")
        gesture.keyDown(code: 0, time: 0.3, isRepeat: false)
        suite.expect(gesture.progress == 0, "another key interrupts the gesture")
        gesture.keyDown(code: 53, time: 1, isRepeat: false)
        gesture.keyDown(code: 53, time: 4, isRepeat: false)
        suite.expect(gesture.progress == 1, "widely spaced Escape presses do not accumulate")
        gesture.keyDown(code: 53, time: 4.3, isRepeat: false)
        gesture.keyDown(code: 53, time: 4.6, isRepeat: false)
        suite.expect(gesture.progress == 3 && !gesture.keyUp(code: 0), "third Escape waits for its own key release")
        suite.expect(gesture.keyUp(code: 53), "three deliberate Escape presses request authentication")
        suite.expect(!gesture.keyUp(code: 53) && gesture.progress == 0, "authentication request is consumed once")
        gesture.keyDown(code: 53, time: 5, isRepeat: false)
        gesture.reset()
        suite.expect(gesture.progress == 0, "cancelled sessions forget their unlock progress")

        let now = Date(timeIntervalSince1970: 1000)
        func session(_ id: String, provider: AgentProvider = .claude, started: Double = 800, activity: Double = 990) -> AgentLiveSession {
            AgentLiveSession(id: id, provider: provider, started: Date(timeIntervalSince1970: started),
                             lastActivity: Date(timeIntervalSince1970: activity), model: "model", project: "/private/project",
                             tokens: AgentTokens(), cost: 0)
        }
        let live = AwayModeSupport.liveSessions([
            session("stale", activity: 399), session("disabled", provider: .codex),
            session("future", activity: 1020), session("b"), session("a"), session("old", started: 700)
        ], enabled: [.claude], now: now)
        suite.expect(live.map(\.id) == ["old", "a", "b"], "live cards exclude stale or disabled agents and remain stable across updates")
        suite.expect(AwayModeSupport.liveSessions([session("a")], enabled: [], now: now).isEmpty,
                     "turning off providers removes their activity")
        suite.expect(!AppFeature.awayMode.installedByDefault && AppFeature.awayMode.permissions == [.accessibility],
                     "Away Mode is opt-in and declares Accessibility")
        suite.expect(AppFeature.awayMode.settingsDestination == FeatureSettingsDestination(.quickTools, sectionAnchor: .awayMode),
                     "feature settings resolve to Away Mode")
        suite.expect(SettingsBackupSupport.exportKeys().contains(DefaultsKey.awayModeShowAgents)
                     && SettingsBackupSupport.exportKeys().contains(DefaultsKey.awayModeKeepAwake), "Away Mode preferences are backed up")
        suite.expect(!GlobalShortcutRole.activeRoles(isOn: { _ in true }, isAvailable: { $0 != .awayMode }).contains(.awayMode),
                     "uninstalled Away Mode cannot register its shortcut")
        suite.expect(!GlobalShortcutRole.activeRoles(isOn: { $0 != DefaultsKey.awayModeShortcutEnabled }).contains(.awayMode),
                     "disabled Away shortcut stays inactive")
        suite.expect(GlobalShortcutRole.activeRoles(isOn: { _ in true }).contains(.awayMode)
                     && GlobalShortcutRole.featuresToSilenceWhileRecording.contains(.awayMode),
                     "Away shortcut participates in shared registration and recorder suspension")
        for key in [DefaultsKey.awayModeShortcut, DefaultsKey.awayModeShortcutEnabled, DefaultsKey.panelUtilityAwayMode] {
            suite.expect(SettingsBackupSupport.exportKeys().contains(key), "shared Away control preference is backed up: \(key)")
        }
        let domain = "vorss.tests.away.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: domain)!
        defer { defaults.removePersistentDomain(forName: domain) }
        defaults.set(true, forKey: AppFeature.awayMode.availabilityKey)
        suite.expect(NotchSupport.controls(in: defaults).contains(.awayMode), "installed Away action joins existing Island controls")
        defaults.set("awayMode,awayMode", forKey: DefaultsKey.notchControlOrder)
        suite.expect(NotchSupport.controls(in: defaults).filter { $0 == .awayMode }.count == 1,
                     "saved Island ordering never duplicates Away action")
        defaults.set("awayMode", forKey: DefaultsKey.notchHiddenControls)
        suite.expect(!NotchSupport.controls(in: defaults).contains(.awayMode), "existing Island visibility preference hides Away action")
        for language in AppLanguage.allCases {
            let strings = AwayModeStrings.get(language)
            suite.expect(!strings.title.isEmpty && !strings.authenticate.isEmpty && strings.unlockHint.contains("3")
                         && !AwayModeStrings.controls(language).working.isEmpty,
                         "Away Mode has a three-press authentication hint in \(language.rawValue)")
        }
    }
}
