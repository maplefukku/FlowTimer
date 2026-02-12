import Foundation
import SwiftUI
import Combine

/// Centralized app settings backed by UserDefaults.
final class AppSettings: ObservableObject {

    enum MenuBarDisplayLevel: Int, CaseIterable, Codable {
        case minimal = 0    // Icon only
        case standard = 1   // Icon + time
        case full = 2       // Icon + time + cycle dots

        var localizedName: String {
            switch self {
            case .minimal: return NSLocalizedString("display.minimal", comment: "Minimal")
            case .standard: return NSLocalizedString("display.standard", comment: "Standard")
            case .full: return NSLocalizedString("display.full", comment: "Full")
            }
        }
    }

    enum NotificationSound: String, CaseIterable, Codable {
        case crystalChime = "crystal_chime"
        case woodenKnock = "wooden_knock"
        case softBell = "soft_bell"
        case windChime = "wind_chime"
        case tibetanBowl = "tibetan_bowl"
        case digitalPulse = "digital_pulse"
        case systemDefault = "system_default"

        var displayName: String {
            switch self {
            case .crystalChime: return "Crystal Chime"
            case .woodenKnock: return "Wooden Knock"
            case .softBell: return "Soft Bell"
            case .windChime: return "Wind Chime"
            case .tibetanBowl: return "Tibetan Bowl"
            case .digitalPulse: return "Digital Pulse"
            case .systemDefault: return "System Default"
            }
        }
    }

    // MARK: - Timer
    @AppStorage("focusDuration") var focusDuration: Int = 25
    @AppStorage("shortBreakDuration") var shortBreakDuration: Int = 5
    @AppStorage("longBreakDuration") var longBreakDuration: Int = 15
    @AppStorage("sessionsPerCycle") var sessionsPerCycle: Int = 4
    @AppStorage("autoStartBreaks") var autoStartBreaks: Bool = true
    @AppStorage("autoStartFocus") var autoStartFocus: Bool = false

    // MARK: - Display
    @AppStorage("menuBarDisplayLevel") var menuBarDisplayLevelRaw: Int = 1 {
        didSet { objectWillChange.send() }
    }

    var menuBarDisplayLevel: MenuBarDisplayLevel {
        get { MenuBarDisplayLevel(rawValue: menuBarDisplayLevelRaw) ?? .standard }
        set { menuBarDisplayLevelRaw = newValue.rawValue }
    }

    // MARK: - Appearance
    @AppStorage("useSystemAccentColor") var useSystemAccentColor: Bool = true
    @AppStorage("customAccentColorHex") var customAccentColorHex: String = "#FF6B6B"

    // MARK: - Notifications
    @AppStorage("soundEnabled") var soundEnabled: Bool = true
    @AppStorage("notificationSound") var notificationSoundRaw: String = "system_default" {
        didSet { objectWillChange.send() }
    }
    @AppStorage("soundVolume") var soundVolume: Double = 0.7
    @AppStorage("hapticEnabled") var hapticEnabled: Bool = true
    @AppStorage("visualNotificationEnabled") var visualNotificationEnabled: Bool = true
    @AppStorage("bannerNotificationEnabled") var bannerNotificationEnabled: Bool = true
    @AppStorage("autoOpenPanelOnComplete") var autoOpenPanelOnComplete: Bool = false

    var notificationSound: NotificationSound {
        get { NotificationSound(rawValue: notificationSoundRaw) ?? .systemDefault }
        set { notificationSoundRaw = newValue.rawValue }
    }

    // MARK: - General
    @AppStorage("launchAtLogin") var launchAtLogin: Bool = false
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("selectedPresetId") var selectedPresetId: String = "standard"

    // MARK: - Accent Color
    var accentColor: Color {
        if useSystemAccentColor {
            return .accentColor
        }
        return Color(hex: customAccentColorHex) ?? .accentColor
    }
}
