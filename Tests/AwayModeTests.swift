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

        gesture.keyDown(code: 53, time: 10, isRepeat: false)
        gesture.keyDown(code: 53, time: 11, isRepeat: true)
        gesture.expire(at: 12)
        suite.expect(gesture.progress == 1, "countdown remains valid at the two-second boundary")
        gesture.expire(at: 12.1)
        suite.expect(gesture.progress == 0, "expired countdown resets without another key; repeats do not extend it")
        for time in [20.0, 20.1, 20.2] { gesture.keyDown(code: 53, time: time, isRepeat: false) }
        gesture.expire(at: 23)
        suite.expect(gesture.keyUp(code: 53), "expiry does not interrupt waiting for the final key release")

        let now = Date(timeIntervalSince1970: 1000)
        func session(_ id: String, provider: AgentProvider = .claude, started: Double = 800, activity: Double = 990) -> AgentLiveSession {
            AgentLiveSession(id: id, provider: provider, started: Date(timeIntervalSince1970: started),
                             lastActivity: Date(timeIntervalSince1970: activity), model: "model", project: "/private/project",
                             tokens: AgentTokens(), cost: 0)
        }
        var activity = AwayAgentActivity()
        activity.update([], enabled: [.claude, .codex], now: now)
        suite.expect(activity.cards.isEmpty, "no activity means no Away cards")
        activity.update([session("one"), session("two", started: 900), session("codex", provider: .codex)],
                        enabled: [.claude, .codex], now: now)
        suite.expect(activity.cards.count == 2 && activity.cards.allSatisfy(\.isWorking),
                     "concurrent providers get separate cards; same-provider sessions are grouped")
        suite.expect(activity.cards.first(where: { $0.provider == .claude })?.elapsed(at: now) == 200,
                     "grouped working card uses the earliest active start")
        activity.receive(.finished(provider: .claude, duration: 42, cost: 0, tokens: 0, project: "private"))
        activity.update([session("one"), session("two", started: 900)], enabled: [.claude, .codex], now: now)
        activity.update([], enabled: [.claude, .codex], now: now)
        suite.expect(activity.cards.count == 1 && activity.cards[0].duration == 42 && !activity.cards[0].isWorking,
                     "completion survives a delayed live snapshot and freezes the reported duration")
        suite.expect(!activity.cards.contains(where: { $0.provider == .codex }),
                     "a disappearing live session is not falsely marked completed")
        activity.update([session("one", started: 999)], enabled: [.claude], now: now)
        suite.expect(activity.cards.count == 1 && activity.cards[0].isWorking,
                     "a new turn in the same session replaces the completed card")
        activity.update([], enabled: [.claude], now: now)
        suite.expect(activity.cards.isEmpty, "stale completion does not return when a new turn goes quiet")
        activity.receive(.finished(provider: .codex, duration: 4, cost: 0, tokens: 0, project: ""))
        suite.expect(activity.cards.isEmpty, "disabled providers cannot introduce completed cards")
        activity.receive(.finished(provider: .claude, duration: 9, cost: 0, tokens: 0, project: ""))
        activity.update([], enabled: [], now: now)
        suite.expect(activity.cards.isEmpty, "disabling the shared integration clears retained cards")

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
        for key in [DefaultsKey.awayModeShortcut, DefaultsKey.awayModeShortcutEnabled, DefaultsKey.panelUtilityAwayMode,
                    DefaultsKey.awayModeOverlayEnabled, DefaultsKey.awayModeOverlayOpacity, DefaultsKey.awayModeBlurIntensity] {
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
            for remaining in 1...3 {
                let hint = AwayModeStrings.escapeCountdown(language, remaining: remaining)
                suite.expect(hint.components(separatedBy: "{esc}").count == 2,
                             "localized sentence contains exactly one inline keycap")
                suite.expect(hint.contains(String(remaining)),
                             "localized hint displays remaining Escape count")
            }
            let appearance = AwayModeStrings.appearance(language)
            suite.expect(!appearance.overlay.isEmpty && !appearance.opacity.isEmpty
                         && !appearance.blur.isEmpty && !appearance.hint.isEmpty,
                         "Away appearance controls are localized in \(language.rawValue)")
            let strings = AwayModeStrings.get(language)
            suite.expect(!strings.title.isEmpty && !strings.authenticate.isEmpty && strings.unlockHint.contains("3")
                         && !AwayModeStrings.controls(language).working.isEmpty,
                         "Away Mode has a three-press authentication hint in \(language.rawValue)")
        }
    }
}
