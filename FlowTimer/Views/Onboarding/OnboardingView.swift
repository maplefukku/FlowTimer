import SwiftUI

/// First launch onboarding experience.
struct OnboardingView: View {
    let appSettings: AppSettings
    let presetManager: PresetManager
    let pomodoroManager: PomodoroManager
    let onComplete: () -> Void

    @State private var currentStep = 0

    private let totalSteps = 4

    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            HStack(spacing: 6) {
                ForEach(0..<totalSteps, id: \.self) { step in
                    Capsule()
                        .fill(step <= currentStep ? Color.accentColor : Color.primary.opacity(0.12))
                        .frame(height: 3)
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            // Content
            Group {
                switch currentStep {
                case 0: welcomeStep
                case 1: menuBarDemoStep
                case 2: presetSelectionStep
                case 3: displayLevelStep
                default: EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 24)

            // Navigation
            HStack {
                if currentStep > 0 {
                    Button(NSLocalizedString("onboarding.back", comment: "Back")) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep -= 1
                        }
                    }
                    .buttonStyle(GlassButtonStyle())
                }

                Spacer()

                Button(currentStep < totalSteps - 1
                    ? NSLocalizedString("onboarding.next", comment: "Next")
                    : NSLocalizedString("onboarding.start", comment: "Let's Start!")
                ) {
                    if currentStep < totalSteps - 1 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                }
                .buttonStyle(GlassButtonStyle(isProminent: true))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .frame(width: 380, height: 480)
    }

    // MARK: - Steps

    private var welcomeStep: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "timer")
                .font(.system(size: 56, weight: .thin))
                .foregroundStyle(.accent)
                .symbolEffect(.pulse, options: .repeating)

            Text("FlowTimer")
                .font(.system(size: 28, weight: .semibold))

            Text(NSLocalizedString("onboarding.welcome.subtitle", comment: ""))
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Spacer()
        }
    }

    private var menuBarDemoStep: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "menubar.arrow.up.rectangle")
                .font(.system(size: 48, weight: .thin))
                .foregroundStyle(.accent)

            Text(NSLocalizedString("onboarding.menuBar.title", comment: "Your Timer Lives Here"))
                .font(.system(size: 20, weight: .semibold))

            Text(NSLocalizedString("onboarding.menuBar.body", comment: ""))
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            // Visual demo
            menuBarPreview
                .padding(.top, 8)

            Spacer()
        }
    }

    private var menuBarPreview: some View {
        HStack(spacing: 8) {
            // Simulated menu bar item
            HStack(spacing: 4) {
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.accentColor, lineWidth: 1.5)
                    .rotationEffect(.degrees(-90))
                    .frame(width: 14, height: 14)

                Text("17:30")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))

                HStack(spacing: 2) {
                    ForEach(0..<4, id: \.self) { i in
                        Circle()
                            .fill(i < 2 ? Color.accentColor : Color.primary.opacity(0.2))
                            .frame(width: 4, height: 4)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.primary.opacity(0.05))
            )
        }
    }

    private var presetSelectionStep: some View {
        VStack(spacing: 16) {
            Text(NSLocalizedString("onboarding.preset.title", comment: "Choose Your Style"))
                .font(.system(size: 20, weight: .semibold))
                .padding(.top, 24)

            Text(NSLocalizedString("onboarding.preset.body", comment: ""))
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 10) {
                ForEach(Preset.builtIn) { preset in
                    presetCard(preset)
                }
            }
            .padding(.top, 8)

            Spacer()
        }
    }

    private func presetCard(_ preset: Preset) -> some View {
        Button(action: {
            presetManager.selectPreset(preset)
        }) {
            HStack(spacing: 12) {
                Image(systemName: preset.icon)
                    .font(.system(size: 18))
                    .frame(width: 32, height: 32)
                    .foregroundStyle(presetManager.activePresetId == preset.id ? .accent : .secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(preset.name)
                        .font(.system(size: 13, weight: .medium))
                    Text("\(preset.focusMinutes) min focus")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if presetManager.activePresetId == preset.id {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.accent)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        presetManager.activePresetId == preset.id
                            ? Color.accentColor.opacity(0.08)
                            : Color.primary.opacity(0.03)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        presetManager.activePresetId == preset.id
                            ? Color.accentColor.opacity(0.2)
                            : Color.primary.opacity(0.06),
                        lineWidth: 0.5
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var displayLevelStep: some View {
        VStack(spacing: 16) {
            Text(NSLocalizedString("onboarding.display.title", comment: "Information Density"))
                .font(.system(size: 20, weight: .semibold))
                .padding(.top, 24)

            Text(NSLocalizedString("onboarding.display.body", comment: ""))
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                ForEach(AppSettings.MenuBarDisplayLevel.allCases, id: \.rawValue) { level in
                    displayLevelOption(level)
                }
            }
            .padding(.top, 8)

            Spacer()
        }
    }

    private func displayLevelOption(_ level: AppSettings.MenuBarDisplayLevel) -> some View {
        Button(action: {
            appSettings.menuBarDisplayLevel = level
        }) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.localizedName)
                        .font(.system(size: 14, weight: .medium))

                    Text(levelDescription(level))
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Mini preview
                levelPreview(level)

                if appSettings.menuBarDisplayLevel == level {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.accent)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        appSettings.menuBarDisplayLevel == level
                            ? Color.accentColor.opacity(0.08)
                            : Color.primary.opacity(0.03)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        appSettings.menuBarDisplayLevel == level
                            ? Color.accentColor.opacity(0.2)
                            : Color.primary.opacity(0.06),
                        lineWidth: 0.5
                    )
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func levelPreview(_ level: AppSettings.MenuBarDisplayLevel) -> some View {
        HStack(spacing: 3) {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(Color.primary.opacity(0.4), lineWidth: 1)
                .rotationEffect(.degrees(-90))
                .frame(width: 10, height: 10)

            if level == .standard || level == .full {
                Text("17:30")
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            if level == .full {
                HStack(spacing: 1) {
                    ForEach(0..<4, id: \.self) { i in
                        Circle()
                            .fill(i < 2 ? Color.primary.opacity(0.5) : Color.primary.opacity(0.15))
                            .frame(width: 3, height: 3)
                    }
                }
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.primary.opacity(0.06))
        )
    }

    private func levelDescription(_ level: AppSettings.MenuBarDisplayLevel) -> String {
        switch level {
        case .minimal:
            return NSLocalizedString("onboarding.display.minimal", comment: "Icon only — ~18px width")
        case .standard:
            return NSLocalizedString("onboarding.display.standard", comment: "Icon + Time — ~80px width")
        case .full:
            return NSLocalizedString("onboarding.display.full", comment: "Icon + Time + Cycle — ~120px width")
        }
    }

    // MARK: - Complete

    private func completeOnboarding() {
        appSettings.hasCompletedOnboarding = true

        if let preset = presetManager.activePreset {
            pomodoroManager.applyPreset(preset)
        }

        onComplete()
    }
}
