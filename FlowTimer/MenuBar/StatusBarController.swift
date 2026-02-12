import AppKit
import SwiftUI
import Combine

/// Manages the NSStatusItem and floating panel window for the menu bar app.
final class StatusBarController: NSObject, ObservableObject {
    private var statusItem: NSStatusItem!
    private var panelWindow: NSWindow!
    private var eventMonitor: Any?

    private let pomodoroManager: PomodoroManager
    private let appSettings: AppSettings
    private let presetManager: PresetManager
    private let sessionStore: SessionStore
    private var cancellables = Set<AnyCancellable>()
    private var iconRenderer: MenuBarIconRenderer!

    private let windowPositionKey = "panelWindowPosition"
    private var windowSizeObserver: NSKeyValueObservation?

    init(
        pomodoroManager: PomodoroManager,
        appSettings: AppSettings,
        presetManager: PresetManager,
        sessionStore: SessionStore
    ) {
        self.pomodoroManager = pomodoroManager
        self.appSettings = appSettings
        self.presetManager = presetManager
        self.sessionStore = sessionStore
        super.init()

        iconRenderer = MenuBarIconRenderer(
            pomodoroManager: pomodoroManager,
            appSettings: appSettings
        )

        setupStatusItem()
        setupPanelWindow()
        observeChanges()
    }

    // MARK: - Setup

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let button = statusItem.button else { return }
        button.target = self
        button.action = #selector(togglePopover)
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])

        updateMenuBarDisplay()
    }

    private func setupPanelWindow() {
        // Create a floating panel window
        let windowSize = NSSize(width: 300, height: 480)
        let window = NSPanel(
            contentRect: NSRect(origin: .zero, size: windowSize),
            styleMask: [.titled, .closable, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        window.title = ""
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.level = .floating // Always on top
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.isMovableByWindowBackground = true
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true

        // Restore saved position or position near menu bar
        if let savedPosition = UserDefaults.standard.string(forKey: windowPositionKey) {
            window.setFrame(from: savedPosition)
        } else {
            positionWindowNearMenuBar(window)
        }

        // Create the SwiftUI content
        let panelView = TimerPanelView()
            .environmentObject(pomodoroManager)
            .environmentObject(appSettings)
            .environmentObject(presetManager)
            .environmentObject(sessionStore)

        window.contentView = NSHostingView(rootView: panelView)

        // Save position when window moves
        NotificationCenter.default.addObserver(
            forName: NSWindow.didMoveNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            self?.saveWindowPosition()
        }

        panelWindow = window

        // Observe window frame changes to preserve center position during resize
        observeWindowResizeForCenterPreservation()
    }

    private func positionWindowNearMenuBar(_ window: NSWindow) {
        guard let button = statusItem.button,
              let screen = button.window?.screen else { return }

        let buttonFrame = button.window?.convertToScreen(button.frame) ?? .zero
        let windowSize = window.frame.size

        var origin = NSPoint(
            x: buttonFrame.midX - windowSize.width / 2,
            y: buttonFrame.minY - windowSize.height - 8
        )

        // Keep window on screen
        let screenFrame = screen.visibleFrame
        origin.x = max(screenFrame.minX, min(origin.x, screenFrame.maxX - windowSize.width))
        origin.y = max(screenFrame.minY, min(origin.y, screenFrame.maxY - windowSize.height))

        window.setFrameOrigin(origin)
    }

    private func saveWindowPosition() {
        guard let window = panelWindow else { return }
        let frameString = window.frameDescriptor
        UserDefaults.standard.set(frameString, forKey: windowPositionKey)
    }

    private func observeWindowResizeForCenterPreservation() {
        // Track the current frame for center calculation
        var previousFrame: NSRect?

        windowSizeObserver = panelWindow.observe(\.frame, options: [.old, .new]) { [weak self] window, change in
            guard let self = self,
                  let newFrame = change.newValue,
                  let oldFrame = change.oldValue,
                  oldFrame.size != newFrame.size else { return }

            // Store the previous frame for next comparison
            if previousFrame == nil {
                previousFrame = oldFrame
            }

            // RING-CENTERED ALIGNMENT:
            // The timer ring is positioned with fixed padding from the window edges:
            // - Top padding: 20px
            // - Horizontal padding: 20px (centered)
            // - Ring size: 180px (fixed)
            //
            // Ring center relative to window:
            // - X: (window.width / 2) - always centered horizontally
            // - Y: 20 (top padding) + 180/2 (half ring size) = 110px from bottom of window

            let ringSize: CGFloat = 180
            let ringTopPadding: CGFloat = 20

            // Calculate ring center in screen coordinates BEFORE resize
            let oldRingCenterX = oldFrame.minX + (oldFrame.width / 2)
            let oldRingCenterY = oldFrame.maxY - ringTopPadding - (ringSize / 2)

            // Calculate where window origin needs to be to keep ring center at same screen position
            let newOriginX = oldRingCenterX - (newFrame.width / 2)
            let newOriginY = oldRingCenterY - (newFrame.height - ringTopPadding - ringSize / 2)

            let newOrigin = NSPoint(x: newOriginX, y: newOriginY)

            // Only update if the origin would actually change
            // This prevents infinite loops
            if abs(newOrigin.x - newFrame.minX) > 0.5 || abs(newOrigin.y - newFrame.minY) > 0.5 {
                // Set new frame with preserved ring center
                var centeredFrame = newFrame
                centeredFrame.origin = newOrigin

                // Temporarily remove observer to prevent recursion
                self.windowSizeObserver?.invalidate()
                window.setFrame(centeredFrame, display: true, animate: false)

                // Re-establish observer
                DispatchQueue.main.async {
                    self.observeWindowResizeForCenterPreservation()
                }
            }

            previousFrame = window.frame
        }
    }

    // MARK: - Observation

    private func observeChanges() {
        // Update menu bar display when timer ticks
        pomodoroManager.timerEngine.$remainingSeconds
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.updateMenuBarDisplay()
                }
            }
            .store(in: &cancellables)

        // Update when session type changes
        pomodoroManager.$currentSession
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.updateMenuBarDisplay()
                }
            }
            .store(in: &cancellables)

        // Update when display level changes
        appSettings.objectWillChange
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.updateMenuBarDisplay()
                }
            }
            .store(in: &cancellables)

        // Update when cycle progress changes
        pomodoroManager.$completedSessionsInCycle
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.updateMenuBarDisplay()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Menu Bar Display

    private func updateMenuBarDisplay() {
        guard let button = statusItem.button else { return }

        let icon = iconRenderer.renderIcon()
        button.image = icon

        let level = appSettings.menuBarDisplayLevel

        switch level {
        case .minimal:
            button.title = ""
        case .standard:
            button.title = " " + pomodoroManager.timerEngine.formattedTime
        case .full:
            let dots = renderCycleDots()
            button.title = " " + pomodoroManager.timerEngine.formattedTime + " " + dots
        }

        button.imagePosition = .imageLeading

        // Set font for the time display
        let font = NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .medium)
        button.font = font
    }

    private func renderCycleDots() -> String {
        let total = appSettings.sessionsPerCycle
        let completed = pomodoroManager.completedSessionsInCycle
        let filled = String(repeating: "●", count: min(completed, total))
        let empty = String(repeating: "○", count: max(total - completed, 0))
        return filled + empty
    }

    // MARK: - Panel Window

    @objc private func togglePopover(_ sender: Any?) {
        guard let event = NSApp.currentEvent else {
            togglePanel()
            return
        }

        // Right-click shows context menu
        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            // Left-click toggles panel
            togglePanel()
        }
    }

    private func showContextMenu() {
        let menu = NSMenu()

        // Show/Hide Panel
        let toggleItem = NSMenuItem(
            title: panelWindow.isVisible ? "Hide Panel" : "Show Panel",
            action: #selector(menuTogglePanel),
            keyEquivalent: ""
        )
        toggleItem.target = self
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())

        // Settings (placeholder - will be implemented later)
        let settingsItem = NSMenuItem(
            title: "Settings",
            action: #selector(menuSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        // Statistics (placeholder - will be implemented later)
        let statsItem = NSMenuItem(
            title: "Statistics",
            action: #selector(menuStatistics),
            keyEquivalent: ""
        )
        statsItem.target = self
        menu.addItem(statsItem)

        // About
        let aboutItem = NSMenuItem(
            title: "About FlowTimer",
            action: #selector(menuAbout),
            keyEquivalent: ""
        )
        aboutItem.target = self
        menu.addItem(aboutItem)

        menu.addItem(NSMenuItem.separator())

        // Quit
        let quitItem = NSMenuItem(
            title: "Quit FlowTimer",
            action: #selector(menuQuit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        // Show menu at status item
        statusItem.menu = menu
        statusItem.button?.performClick(nil)

        // Clear menu after it's shown to restore click behavior
        DispatchQueue.main.async { [weak self] in
            self?.statusItem.menu = nil
        }
    }

    // MARK: - Menu Actions

    @objc private func menuTogglePanel() {
        togglePanel()
    }

    @objc private func menuSettings() {
        // Open the Settings window via AppDelegate
        if let appDelegate = NSApp.delegate as? AppDelegate {
            appDelegate.showSettings()
        }
    }

    @objc private func menuStatistics() {
        // Show panel with statistics tab selected
        // For now, just show the panel
        showPanel()
    }

    @objc private func menuAbout() {
        let alert = NSAlert()
        alert.messageText = "FlowTimer"
        alert.informativeText = "A Pomodoro timer for macOS\n\nVersion 1.0\n\n© 2025"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc private func menuQuit() {
        NSApplication.shared.terminate(nil)
    }

    func showPopover() {
        showPanel()
    }

    func closePopover() {
        closePanel()
    }

    func togglePanel() {
        if panelWindow.isVisible {
            closePanel()
        } else {
            showPanel()
        }
    }

    private func showPanel() {
        panelWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func closePanel() {
        panelWindow.orderOut(nil)
    }

    // MARK: - Onboarding

    func showOnboarding() {
        // Store reference to original window
        let originalWindow = panelWindow

        let onboardingView = OnboardingView(
            appSettings: appSettings,
            presetManager: presetManager,
            pomodoroManager: pomodoroManager,
            onComplete: { [weak self] in
                // Close the onboarding window
                self?.panelWindow?.close()
                // Restore the original panel window immediately
                self?.panelWindow = originalWindow
            }
        )

        // Create temporary onboarding window
        let onboardingWindow = NSPanel(
            contentRect: NSRect(origin: .zero, size: NSSize(width: 380, height: 480)),
            styleMask: [.titled, .closable, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        onboardingWindow.title = "Welcome to FlowTimer"
        onboardingWindow.level = .floating
        onboardingWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        onboardingWindow.isMovableByWindowBackground = true
        onboardingWindow.center()
        onboardingWindow.contentView = NSHostingView(rootView: onboardingView)

        // Replace panel window with onboarding window
        panelWindow = onboardingWindow

        showPanel()
    }
}
