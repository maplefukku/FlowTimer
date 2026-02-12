import AppKit
import Carbon

/// Registers and manages global keyboard shortcuts using the Carbon Hot Key API.
final class HotKeyService {
    private let pomodoroManager: PomodoroManager
    private weak var statusBarController: StatusBarController?
    private var hotKeyRefs: [EventHotKeyRef?] = []
    private var eventHandler: EventHandlerRef?

    // Hot key IDs
    private static let togglePanelID: UInt32 = 1    // ⌘⇧P
    private static let startStopID: UInt32 = 2       // ⌘⇧S
    private static let resetID: UInt32 = 3           // ⌘⇧R
    private static let skipBreakID: UInt32 = 4       // ⌘⇧K
    private static let preset1ID: UInt32 = 5         // ⌘⇧1
    private static let preset2ID: UInt32 = 6         // ⌘⇧2
    private static let preset3ID: UInt32 = 7         // ⌘⇧3
    private static let preset4ID: UInt32 = 8         // ⌘⇧4

    init(pomodoroManager: PomodoroManager, statusBarController: StatusBarController?) {
        self.pomodoroManager = pomodoroManager
        self.statusBarController = statusBarController
    }

    func registerHotKeys() {
        // Install event handler
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let handler: EventHandlerUPP = { _, event, userData -> OSStatus in
            guard let userData = userData else { return noErr }
            let service = Unmanaged<HotKeyService>.fromOpaque(userData).takeUnretainedValue()
            return service.handleHotKey(event: event!)
        }

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        InstallEventHandler(
            GetApplicationEventTarget(),
            handler,
            1,
            &eventType,
            selfPtr,
            &eventHandler
        )

        // Register individual hot keys
        // Modifiers: cmdKey = 0x0100, shiftKey = 0x0200
        let cmdShift: UInt32 = UInt32(cmdKey | shiftKey)

        registerHotKey(id: Self.togglePanelID, keyCode: kVK_ANSI_P, modifiers: cmdShift)
        registerHotKey(id: Self.startStopID, keyCode: kVK_ANSI_S, modifiers: cmdShift)
        registerHotKey(id: Self.resetID, keyCode: kVK_ANSI_R, modifiers: cmdShift)
        registerHotKey(id: Self.skipBreakID, keyCode: kVK_ANSI_K, modifiers: cmdShift)
        registerHotKey(id: Self.preset1ID, keyCode: kVK_ANSI_1, modifiers: cmdShift)
        registerHotKey(id: Self.preset2ID, keyCode: kVK_ANSI_2, modifiers: cmdShift)
        registerHotKey(id: Self.preset3ID, keyCode: kVK_ANSI_3, modifiers: cmdShift)
        registerHotKey(id: Self.preset4ID, keyCode: kVK_ANSI_4, modifiers: cmdShift)
    }

    func unregisterHotKeys() {
        for ref in hotKeyRefs {
            if let ref = ref {
                UnregisterEventHotKey(ref)
            }
        }
        hotKeyRefs.removeAll()

        if let handler = eventHandler {
            RemoveEventHandler(handler)
            eventHandler = nil
        }
    }

    // MARK: - Private

    private func registerHotKey(id: UInt32, keyCode: Int, modifiers: UInt32) {
        let hotKeyID = EventHotKeyID(signature: OSType(0x464C5754), id: id) // "FLWT"
        var hotKeyRef: EventHotKeyRef?

        let status = RegisterEventHotKey(
            UInt32(keyCode),
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        if status == noErr {
            hotKeyRefs.append(hotKeyRef)
        }
    }

    private func handleHotKey(event: EventRef) -> OSStatus {
        var hotKeyID = EventHotKeyID()
        let status = GetEventParameter(
            event,
            UInt32(kEventParamDirectObject),
            UInt32(typeEventHotKeyID),
            nil,
            MemoryLayout<EventHotKeyID>.size,
            nil,
            &hotKeyID
        )

        guard status == noErr else { return status }

        DispatchQueue.main.async { [weak self] in
            self?.dispatchHotKey(id: hotKeyID.id)
        }

        return noErr
    }

    private func dispatchHotKey(id: UInt32) {
        switch id {
        case Self.togglePanelID:
            statusBarController?.togglePanel()
        case Self.startStopID:
            pomodoroManager.startOrPause()
        case Self.resetID:
            pomodoroManager.reset()
        case Self.skipBreakID:
            if pomodoroManager.isOnBreak {
                pomodoroManager.skipToNext()
            }
        case Self.preset1ID:
            applyPresetByIndex(0)
        case Self.preset2ID:
            applyPresetByIndex(1)
        case Self.preset3ID:
            applyPresetByIndex(2)
        case Self.preset4ID:
            applyPresetByIndex(3)
        default:
            break
        }
    }

    private func applyPresetByIndex(_ index: Int) {
        let presets = Preset.builtIn
        guard index < presets.count else { return }
        pomodoroManager.applyPreset(presets[index])
    }

    deinit {
        unregisterHotKeys()
    }
}
