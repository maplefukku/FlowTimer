import AVFoundation
import AppKit

/// Plays notification sounds using AVFoundation.
final class SoundService {
    private var player: AVAudioPlayer?

    func playCompletionSound(sound: AppSettings.NotificationSound, volume: Float) {
        if sound == .systemDefault {
            playSystemSound()
            return
        }

        // Try to load bundled sound file
        if let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "aiff")
            ?? Bundle.main.url(forResource: sound.rawValue, withExtension: "wav")
            ?? Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.volume = volume
                player?.play()
                return
            } catch {
                // Fall through to system sound
            }
        }

        // Fallback to system sound
        playSystemSound()
    }

    private func playSystemSound() {
        NSSound.beep()
    }

    func playPreview(sound: AppSettings.NotificationSound, volume: Float) {
        playCompletionSound(sound: sound, volume: volume)
    }
}
