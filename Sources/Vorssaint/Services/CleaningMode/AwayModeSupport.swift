// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// Wait for the third Escape's release before giving macOS authentication the
/// keyboard. Otherwise that release can dismiss the authentication sheet.
struct AwayUnlockGesture {
    private var counter = CleaningUnlockCounter(requiredKeyCode: 53, threshold: 3, pressWindow: 2)
    private var awaitingRelease = false
    var progress: Int { counter.progress }

    mutating func keyDown(code: Int64, time: TimeInterval, isRepeat: Bool) {
        guard !awaitingRelease else { return }
        awaitingRelease = counter.registerKeyDown(code: code, time: time, isRepeat: isRepeat)
    }

    mutating func keyUp(code: Int64) -> Bool {
        guard code == 53, awaitingRelease else { return false }
        reset()
        return true
    }

    mutating func reset() {
        counter.reset()
        awaitingRelease = false
    }
}

enum AwayModeSupport {
    /// Keep a stable order as several agents write concurrently. Never expose
    /// project paths, prompts, transcripts or work from disabled providers.
    static func liveSessions(_ sessions: [AgentLiveSession], enabled: Set<AgentProvider>, now: Date) -> [AgentLiveSession] {
        sessions.filter {
            enabled.contains($0.provider) && now.timeIntervalSince($0.lastActivity) < 600
                && now.timeIntervalSince($0.lastActivity) >= -5
        }.sorted {
            if $0.started != $1.started { return $0.started < $1.started }
            return $0.id < $1.id
        }
    }
}
