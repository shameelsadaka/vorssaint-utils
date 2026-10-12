// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// Wait for the third Escape's release before giving macOS authentication the
/// keyboard. Otherwise that release can dismiss the authentication sheet.
struct AwayUnlockGesture {
    private var counter = CleaningUnlockCounter(requiredKeyCode: 53, threshold: 3, pressWindow: 2)
    private var awaitingRelease = false
    private var lastPress: TimeInterval?
    var progress: Int { counter.progress }

    mutating func keyDown(code: Int64, time: TimeInterval, isRepeat: Bool) {
        guard !awaitingRelease else { return }
        if !isRepeat { lastPress = code == 53 ? time : nil }
        awaitingRelease = counter.registerKeyDown(code: code, time: time, isRepeat: isRepeat)
    }

    mutating func keyUp(code: Int64) -> Bool {
        guard code == 53, awaitingRelease else { return false }
        reset()
        return true
    }

    mutating func expire(at time: TimeInterval) {
        guard !awaitingRelease, let lastPress, time - lastPress > 2 else { return }
        reset()
    }

    mutating func reset() {
        lastPress = nil
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


/// Only activity observed during this Away session is retained. Disappearing
/// from a live snapshot is not proof of completion (it may mean waiting).
struct AwayAgentActivity: Equatable {
    struct Card: Identifiable, Equatable {
        let provider: AgentProvider
        let started: Date?
        let duration: TimeInterval?
        var id: AgentProvider { provider }
        var isWorking: Bool { started != nil }
        func elapsed(at now: Date) -> TimeInterval {
            max(0, started.map { now.timeIntervalSince($0) } ?? duration ?? 0)
        }
    }

    private var live: [AgentLiveSession] = []
    private var completed: [AgentProvider: TimeInterval] = [:]
    private var enabled: Set<AgentProvider> = []

    var cards: [Card] {
        AgentProvider.allCases.compactMap { provider in
            guard enabled.contains(provider) else { return nil }
            if let started = live.filter({ $0.provider == provider }).map(\.started).min() {
                return Card(provider: provider, started: started, duration: nil)
            }
            return completed[provider].map { Card(provider: provider, started: nil, duration: $0) }
        }
    }

    mutating func update(_ sessions: [AgentLiveSession], enabled: Set<AgentProvider>, now: Date) {
        self.enabled = enabled
        let previous = live
        live = AwayModeSupport.liveSessions(sessions, enabled: enabled, now: now)
        completed = completed.filter { enabled.contains($0.key) }
        // A new working turn supersedes the previous completed card.
        for session in live where !previous.contains(where: { $0.id == session.id && $0.started == session.started }) {
            completed.removeValue(forKey: session.provider)
        }
    }

    mutating func receive(_ event: AgentUsageEvent) {
        guard case .finished(let provider, let duration, _, _, _) = event,
              enabled.contains(provider), duration.isFinite, duration >= 0 else { return }
        completed[provider] = duration
    }
}
