import Foundation

struct Preset: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var focusMinutes: Int
    var shortBreakMinutes: Int
    var longBreakMinutes: Int
    var soundEnabled: Bool
    var hapticEnabled: Bool
    var icon: String

    static let builtInIds = Set(["deepFocus", "standard", "quickSprint", "creativeFlow"])

    static let builtIn: [Preset] = [
        Preset(
            id: "deepFocus",
            name: NSLocalizedString("preset.deepFocus", comment: "Deep Focus"),
            focusMinutes: 50,
            shortBreakMinutes: 10,
            longBreakMinutes: 30,
            soundEnabled: false,
            hapticEnabled: true,
            icon: "brain.head.profile"
        ),
        Preset(
            id: "standard",
            name: NSLocalizedString("preset.standard", comment: "Standard"),
            focusMinutes: 25,
            shortBreakMinutes: 5,
            longBreakMinutes: 15,
            soundEnabled: true,
            hapticEnabled: true,
            icon: "timer"
        ),
        Preset(
            id: "quickSprint",
            name: NSLocalizedString("preset.quickSprint", comment: "Quick Sprint"),
            focusMinutes: 15,
            shortBreakMinutes: 3,
            longBreakMinutes: 10,
            soundEnabled: true,
            hapticEnabled: false,
            icon: "hare"
        ),
        Preset(
            id: "creativeFlow",
            name: NSLocalizedString("preset.creativeFlow", comment: "Creative Flow"),
            focusMinutes: 45,
            shortBreakMinutes: 10,
            longBreakMinutes: 20,
            soundEnabled: false,
            hapticEnabled: true,
            icon: "paintbrush"
        ),
    ]
}
