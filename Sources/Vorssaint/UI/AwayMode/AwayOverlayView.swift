// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import SwiftUI

/// Blackout panels cover every display. Only the chosen Island display gets
/// content; the usual interactive Island is underneath, with no duplicate UI.
struct AwayOverlayView: View {
    let geometry: NotchGeometry?

    var body: some View {
        ZStack(alignment: .top) {
            Color.black
            if let geometry { AwayActivityView(geometry: geometry) }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

private struct AwayActivityView: View {
    let geometry: NotchGeometry
    @ObservedObject private var agents = AgentUsageService.shared
    @ObservedObject private var l10n = L10n.shared
    @AppStorage(DefaultsKey.awayModeShowAgents) private var showAgents = true
    @State private var finished: (provider: AgentProvider, at: Date, duration: TimeInterval)?

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            let enabled = showAgents && NotchAgentSupport.isEnabled()
            let providers = Set(NotchAgentSupport.providers())
            let sessions = enabled ? AwayModeSupport.liveSessions(
                agents.snapshot.live, enabled: providers, now: timeline.date) : []
            let completion = enabled ? finished.flatMap {
                timeline.date.timeIntervalSince($0.at) < 20 && providers.contains($0.provider) ? $0 : nil
            } : nil
            AwayIslandView(geometry: geometry, sessions: sessions,
                           finishedProvider: completion?.provider,
                           finishedDuration: completion?.duration ?? 0,
                           now: timeline.date, language: l10n.language)
        }
        .onReceive(agents.events) { event in
            guard showAgents, NotchAgentSupport.isEnabled() else { return }
            if case let .finished(provider, duration, _, _, _) = event,
               NotchAgentSupport.providers().contains(provider) {
                finished = (provider, Date(), duration)
            }
        }
    }
}

/// A passive Island surface using the same outline, agent marks and card
/// chrome as the interactive Island. No titles, idle captions or exit hints.
struct AwayIslandView: View {
    let geometry: NotchGeometry
    let sessions: [AgentLiveSession]
    var finishedProvider: AgentProvider? = nil
    var finishedDuration: TimeInterval = 0
    let now: Date
    let language: AppLanguage
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var resting: Bool { sessions.isEmpty && finishedProvider == nil }
    private var width: CGFloat {
        min(geometry.screen.width - 24, max(geometry.cameraWidth + 32, resting ? 164 : 366))
    }
    private var bodyHeight: CGFloat {
        resting ? 36 : CGFloat(max(1, min(3, sessions.count))) * 62
            + CGFloat(max(0, min(3, sessions.count) - 1)) * 7 + (sessions.count > 3 ? 18 : 0)
    }
    private var height: CGFloat { geometry.safeContentTop + bodyHeight + 12 }

    var body: some View {
        VStack(spacing: 7) {
            if !sessions.isEmpty {
                ForEach(Array(sessions.prefix(3))) { session in
                    card(provider: session.provider, finished: false,
                         duration: max(0, now.timeIntervalSince(session.started)))
                }
                if sessions.count > 3 {
                    Text("+\(sessions.count - 3)")
                        .font(.system(size: 11)).foregroundStyle(.secondary)
                }
            } else if let finishedProvider {
                card(provider: finishedProvider, finished: true, duration: finishedDuration)
            } else {
                AwayOrbitView().frame(width: 52, height: 36)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, geometry.safeContentTop)
        .padding(.bottom, 12)
        .frame(width: width, height: height)
        .background(Color(white: 0.025), in: NotchShape.island(height: height, geometry: geometry))
        .environment(\.colorScheme, .dark)
        .environment(\.notchGlassSurface, true)
        .padding(.top, geometry.floatingDrop)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: height)
        .allowsHitTesting(false)
    }

    private func card(provider: AgentProvider, finished: Bool, duration: TimeInterval) -> some View {
        HStack(spacing: 12) {
            if finished {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 22, weight: .light)).foregroundStyle(.green)
                    .frame(width: 26)
            } else {
                NotchAgentMark(provider: provider, size: 22, tint: provider.tint).frame(width: 26)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(finished
                     ? String(format: FeatureStrings.notchAgents(language).finishedFormat, provider.displayName)
                     : provider.displayName)
                    .font(.system(size: 13, weight: .medium)).foregroundStyle(.white.opacity(0.88))
                if !finished {
                    Text(AwayModeStrings.controls(language).working)
                        .font(.system(size: 11)).foregroundStyle(.white.opacity(0.5))
                }
            }
            .lineLimit(1)
            Spacer(minLength: 4)
            Text(AgentFormat.duration(duration, locale: language.formattingLocale()))
                .font(.system(size: 11, design: .monospaced)).foregroundStyle(.white.opacity(0.62))
                .fixedSize()
        }
        .padding(.horizontal, 14)
        .frame(height: 62)
        .modifier(NotchControlSurface(cornerRadius: 13, interactive: false))
    }
}

/// An original, understated orbit mark, independent of upstream's app artwork.
private struct AwayOrbitView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.2, paused: reduceMotion)) { timeline in
            let phase = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate / 9
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let planet = CGRect(x: center.x - 8, y: center.y - 8, width: 16, height: 16)
                context.fill(Path(ellipseIn: planet), with: .linearGradient(
                    Gradient(colors: [.white.opacity(0.26), .white.opacity(0.04)]),
                    startPoint: CGPoint(x: planet.minX, y: planet.minY),
                    endPoint: CGPoint(x: planet.maxX, y: planet.maxY)))
                context.translateBy(x: center.x, y: center.y)
                context.rotate(by: .degrees(-24))
                context.stroke(Path(ellipseIn: CGRect(x: -23, y: -7, width: 46, height: 14)),
                               with: .color(.white.opacity(0.22)), lineWidth: 1)
                let dot = CGRect(x: cos(phase) * 23 - 1, y: sin(phase) * 7 - 1, width: 2, height: 2)
                context.fill(Path(ellipseIn: dot), with: .color(.white.opacity(0.6)))
            }
        }
        .accessibilityHidden(true)
    }
}
