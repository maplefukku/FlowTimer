import Foundation
import Combine

/// Manages timer presets (built-in and custom).
final class PresetManager: ObservableObject {
    @Published var presets: [Preset] = Preset.builtIn
    @Published var activePresetId: String = "standard"

    var activePreset: Preset? {
        presets.first { $0.id == activePresetId }
    }

    init() {
        loadCustomPresets()
    }

    func selectPreset(_ preset: Preset) {
        activePresetId = preset.id
        UserDefaults.standard.set(preset.id, forKey: "selectedPresetId")
    }

    func selectPresetByIndex(_ index: Int) {
        let builtInPresets = Preset.builtIn
        guard index >= 0 && index < builtInPresets.count else { return }
        selectPreset(builtInPresets[index])
    }

    // MARK: - Persistence

    private func loadCustomPresets() {
        if let data = UserDefaults.standard.data(forKey: "customPresets"),
           let custom = try? JSONDecoder().decode([Preset].self, from: data) {
            presets = Preset.builtIn + custom
        }
        if let savedId = UserDefaults.standard.string(forKey: "selectedPresetId") {
            activePresetId = savedId
        }
    }

    func saveCustomPresets() {
        let custom = presets.filter { !Preset.builtInIds.contains($0.id) }
        if let data = try? JSONEncoder().encode(custom) {
            UserDefaults.standard.set(data, forKey: "customPresets")
        }
    }
}
