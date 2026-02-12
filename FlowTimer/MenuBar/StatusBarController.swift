import AppKit
import SwiftUI
import Combine

/// Manages the NSStatusItem and NSPopover for the menu bar app.
final class StatusBarController: NSObject, ObservableObject {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var eventMonitor: Any?

    private let pomodoroManager: PomodoroManager
    private let appSettings: AppSettings
    private let presetManager: PresetManager
    private let sessionStore: SessionStore
    private var cancellables = Set<AnyCancellable>()
    private var iconRenderer: MenuBarIconRenderer!

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
        setupPopover()
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

    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 420)
        popover.behavior = .transient
        popover.animates = true

        let panelView = TimerPanelView()
            .environmentObject(pomodoroManager)
            .environmentObject(appSettings)
            .environmentObject(presetManager)
            .environmentObject(sessionStore)

        popover.contentViewController = NSHostingController(rootView: panelView)
    }

    // MARK: - Observation

    private func observeChanges() {
        // Update menu bar display when timer ticks
        pomodoroManager.timerEngine.$remainingSeconds
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateMenuBarDisplay()
            }
            .store(in: &cancellables)

        // Update when session type changes
        pomodoroManager.$currentSession
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateMenuBarDisplay()
            }
            .store(in: &cancellables)

        // Update when display level changes
        appSettings.$menuBarDisplayLevelRaw
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateMenuBarDisplay()
            }
            .store(in: &cancellables)

        // Update when cycle progress changes
        pomodoroManager.$completedSessionsInCycle
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateMenuBarDisplay()
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

    // MARK: - Popover

    @objc private func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }

    func showPopover() {
        guard let button = statusItem.button else { return }
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)

        // Monitor clicks outside popover to close it
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.closePopover()
        }
    }

    func closePopover() {
        popover.performClose(nil)
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    func togglePanel() {
        if popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }

    // MARK: - Onboarding

    func showOnboarding() {
        let onboardingView = OnboardingView(
            appSettings: appSettings,
            presetManager: presetManager,
            pomodoroManager: pomodoroManager,
            onComplete: { [weak self] in
                self?.closePopover()
                self?.setupPopover() // Reset to normal panel
            }
        )

        let popoverForOnboarding = NSPopover()
        popoverForOnboarding.contentSize = NSSize(width: 380, height: 480)
        popoverForOnboarding.behavior = .applicationDefined
        popoverForOnboarding.animates = true
        popoverForOnboarding.contentViewController = NSHostingController(rootView: onboardingView)

        // Swap popover temporarily
        let originalPopover = popover
        popover = popoverForOnboarding

        showPopover()

        // Restore original popover setup after onboarding dismissal
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            if let original = originalPopover {
                self?.popover = original
            }
        }
    }
}
