// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import SwiftUI

/// A centered logo on every display over a dimmed, blurred desktop.
/// Menu bar and Island launch actions remain separate from this passive screen.
struct AwayOverlayView: View {
    let displaySize: CGSize
    @ObservedObject private var manager = CleaningModeManager.shared
    @ObservedObject private var l10n = L10n.shared
    @AppStorage(DefaultsKey.awayModeShowAgents) private var showAgents = true
    @AppStorage(DefaultsKey.awayModeOverlayEnabled) private var overlayEnabled = true
    @AppStorage(DefaultsKey.awayModeOverlayOpacity) private var overlayOpacity = 0.5
    @AppStorage(DefaultsKey.awayModeBlurIntensity) private var blurIntensity = 1.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        ZStack {
            if overlayEnabled {
                if !reduceTransparency, blurIntensity > 0 {
                    AwayBackdropBlur(intensity: min(1, max(0, blurIntensity)))
                }
                Color.black.opacity(reduceTransparency ? 1 : min(1, max(0, overlayOpacity)))
                if !AwayLogoFrames.images.isEmpty {
                    TimelineView(.animation(minimumInterval: 0.24, paused: reduceMotion)) { timeline in
                        let elapsed = max(0, timeline.date.timeIntervalSinceReferenceDate)
                        let index = reduceMotion ? 0 : Int(elapsed / 0.24) % AwayLogoFrames.images.count
                        Image(nsImage: AwayLogoFrames.images[index])
                            .resizable()
                            .interpolation(.high)
                            // Match the approved 1512-point MacBook display on every
                            // monitor. Points preserve UI size across Retina scales.
                            .frame(width: 201, height: 201 * 440.0 / 640.0)
                            .accessibilityHidden(true)
                    }
                }
                if showAgents, !manager.awayAgentActivity.cards.isEmpty {
                    AwayAgentCards(cards: manager.awayAgentActivity.cards, language: l10n.language)
                        .frame(width: min(manager.awayAgentActivity.cards.count == 1 ? 246 : 500, max(220, displaySize.width - 48)))
                        .frame(height: 144, alignment: .top)
                        .offset(y: 201 * 440.0 / 640.0 / 2 + 20 + 72)
                }
            }
        }
        .frame(width: displaySize.width, height: displaySize.height)
        .overlay(alignment: .bottom) {
            if overlayEnabled, !manager.isAuthenticating {
                AwayUnlockHint(isEscapePressed: manager.isAwayEscapePressed,
                               isEnterPressed: manager.isAwayEnterPressed,
                               text: AwayModeStrings.unlockPrompt(l10n.language))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

private enum AwayLogoFrames {
    // Load once, not on each animation tick. Frames preserve the approved
    // prototype's crop, planet alignment, dimensions and timing.
    static let images: [NSImage] = (0..<12).compactMap { index in
        guard let url = Bundle.main.url(forResource: String(format: "AwayLogo-%02d", index),
                                        withExtension: "png", subdirectory: "Images") else { return nil }
        return NSImage(contentsOf: url)
    }
}

/// Native behind-window blur keeps desktop contents frosted without capture.
private struct AwayBackdropBlur: NSViewRepresentable {
    let intensity: Double

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .hudWindow
        view.blendingMode = .behindWindow
        view.state = .active
        view.appearance = NSAppearance(named: .darkAqua)
        view.alphaValue = intensity
        return view
    }

    func updateNSView(_ view: NSVisualEffectView, context: Context) {
        // AppKit owns the blur radius; blend the material to control intensity.
        view.alphaValue = intensity
    }
}


/// A keyboard cue, rather than a button: input remains handled by the guard.
private struct AwayUnlockHint: View {
    let isEscapePressed: Bool
    let isEnterPressed: Bool
    let text: String

    var body: some View {
        let parts = text.replacingOccurrences(of: "{enter}", with: "{esc}")
            .components(separatedBy: "{esc}")
        HStack(spacing: 6) {
            caption(parts[0])
            AwayUnlockKeycap(label: "enter", isPressed: isEnterPressed, width: 44)
            caption(parts[1])
            AwayUnlockKeycap(label: "esc", isPressed: isEscapePressed, width: 34)
            caption(parts[2])
        }
        .shadow(color: .black.opacity(0.3), radius: 3, y: 1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text.replacingOccurrences(of: "{enter}", with: "Enter")
            .replacingOccurrences(of: "{esc}", with: "Escape"))
    }

    private func caption(_ value: String) -> some View {
        Text(value.trimmingCharacters(in: .whitespaces))
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.white.opacity(0.6))
    }
}

private struct AwayUnlockKeycap: View {
    let label: String
    let isPressed: Bool
    let width: CGFloat
    @State private var keycapDown = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Text(label)
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundStyle(.white.opacity(0.85))
            .frame(width: width, height: 25)
            .background(.white.opacity(keycapDown ? 0.18 : 0.07), in: RoundedRectangle(cornerRadius: 6))
            .overlay {
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(.white.opacity(keycapDown ? 0.4 : 0.22), lineWidth: 0.75)
            }
            .shadow(color: .black.opacity(0.25), radius: 0, y: 2)
            .scaleEffect(reduceMotion || !keycapDown ? 1 : 0.94, anchor: .center)
            .animation(reduceMotion ? nil : .spring(response: 0.2, dampingFraction: 0.7), value: keycapDown)
            .task(id: isPressed) {
                if isPressed {
                    keycapDown = true
                } else {
                    do { try await Task.sleep(for: .milliseconds(100)) }
                    catch { return }
                    keycapDown = false
                }
            }
    }
}


/// Reuses the Island's surface, provider marks, status pulse and elapsed clock.
private struct AwayAgentCards: View {
    let cards: [AwayAgentActivity.Card]
    let language: AppLanguage

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: min(2, max(1, cards.count))), spacing: 8) {
                ForEach(cards) { card in
                    NotchAgentCardChrome {
                        VStack(alignment: .leading, spacing: 6) {
                            NotchAgentCardHeader(title: card.provider.displayName, symbol: card.provider.symbol,
                                                 tint: card.provider.tint, provider: card.provider) {
                                if card.isWorking {
                                    NotchAgentPulse(tint: card.provider.tint, size: 4)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 11)).foregroundStyle(.green)
                                }
                            }
                            HStack {
                                Text(card.isWorking ? AwayModeStrings.controls(language).working
                                     : FeatureStrings.notchAgents(language).finished(card.provider.displayName))
                                    .lineLimit(1)
                                Spacer(minLength: 4)
                                Text(AgentFormat.clock(card.elapsed(at: context.date))).monospacedDigit()
                            }
                            .font(.system(size: 10.5, weight: .medium))
                            .foregroundStyle(.white.opacity(0.65))
                        }
                    }
                    .frame(height: 64)
                }
            }
        }
        .environment(\.colorScheme, .dark)
    }
}
