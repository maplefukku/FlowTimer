import AppKit

/// Provides haptic feedback on MacBooks with Taptic Engine.
final class HapticService {
    func playCompletion() {
        let performer = NSHapticFeedbackManager.defaultPerformer
        performer.perform(.alignment, performanceTime: .default)

        // Play a sequence for more noticeable feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            performer.perform(.levelChange, performanceTime: .default)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            performer.perform(.alignment, performanceTime: .default)
        }
    }

    func playTick() {
        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
    }
}
