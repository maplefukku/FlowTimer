import SwiftUI

/// The main expanded panel view shown when the menu bar is clicked.
struct TimerPanelView: View {
    @EnvironmentObject var pomodoroManager: PomodoroManager
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var presetManager: PresetManager
    @EnvironmentObject var sessionStore: SessionStore

    @State private var showingStatistics = false
    @State private var isMinimalMode = false
    @Namespace private var timerNamespace

    // Fixed timer ring size for pixel-perfect alignment
    private let timerRingSize: CGFloat = 180

    // Animation constants for rich transitions
    private let springResponse: Double = 0.55
    private let springDamping: Double = 0.75
    private let backgroundSpringResponse: Double = 0.65
    private let backgroundSpringDamping: Double = 0.78

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if isMinimalMode {
                    minimalView
                } else {
                    fullView
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .frame(
            width: isMinimalMode ? 220 : 300,
            height: isMinimalMode ? 220 : 480
        )
        .sheet(isPresented: $showingStatistics) {
            StatisticsView()
                .environmentObject(sessionStore)
                .frame(minWidth: 500, minHeight: 400)
        }
        .onKeyPress(.space) {
            pomodoroManager.startOrPause()
            return .handled
        }
        .onKeyPress(.escape) {
            // Close handled by popover
            return .ignored
        }
        .onChange(of: pomodoroManager.isTimerActive) { oldValue, newValue in
            // Auto-switch to minimal mode when timer starts/resumes
            if !oldValue && newValue {
                withAnimation(.spring(response: springResponse, dampingFraction: springDamping)) {
                    isMinimalMode = true
                }
            }
        }
    }

    private var fullView: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // Timer area with fixed position
                VStack(spacing: 12) {
                    // Session label - smooth fade and slide
                    sessionLabel
                        .opacity(isMinimalMode ? 0 : 1)
                        .scaleEffect(isMinimalMode ? 0.9 : 1.0, anchor: .center)
                        .offset(y: isMinimalMode ? -5 : 0)
                        .blur(radius: isMinimalMode ? 2 : 0)
                        .frame(height: isMinimalMode ? 0 : nil)
                        .animation(.spring(response: springResponse, dampingFraction: springDamping), value: isMinimalMode)

                    // Timer ring - FIXED SIZE AND POSITION with matched geometry
                    ZStack {
                        TimerRingView(showCurrentTime: isMinimalMode, currentTimeString: currentTimeString)
                            .frame(width: timerRingSize, height: timerRingSize)
                            .contentShape(Circle())
                            .matchedGeometryEffect(id: "timerRing", in: timerNamespace)
                            .onTapGesture {
                                withAnimation(.spring(response: springResponse, dampingFraction: springDamping)) {
                                    isMinimalMode.toggle()
                                }
                            }
                    }
                    .frame(height: timerRingSize)

                    // Cycle indicator - smooth fade and slide
                    cycleIndicator
                        .opacity(isMinimalMode ? 0 : 1)
                        .scaleEffect(isMinimalMode ? 0.9 : 1.0, anchor: .center)
                        .offset(y: isMinimalMode ? 5 : 0)
                        .blur(radius: isMinimalMode ? 2 : 0)
                        .frame(height: isMinimalMode ? 0 : nil)
                        .animation(.spring(response: springResponse, dampingFraction: springDamping).delay(0.02), value: isMinimalMode)
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)

                // Controls - staggered animation
                TimerControlsView()
                    .padding(.top, 16)
                    .padding(.horizontal, 20)
                    .opacity(isMinimalMode ? 0 : 1)
                    .scaleEffect(isMinimalMode ? 0.95 : 1.0, anchor: .top)
                    .offset(y: isMinimalMode ? -8 : 0)
                    .blur(radius: isMinimalMode ? 3 : 0)
                    .frame(height: isMinimalMode ? 0 : nil)
                    .animation(.spring(response: springResponse, dampingFraction: springDamping).delay(0.04), value: isMinimalMode)

                Divider()
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .opacity(isMinimalMode ? 0 : 1)
                    .frame(height: isMinimalMode ? 0 : nil)
                    .animation(.spring(response: springResponse, dampingFraction: springDamping).delay(0.05), value: isMinimalMode)

                // Quick stats - staggered animation
                QuickStatsView()
                    .padding(.top, 12)
                    .padding(.horizontal, 20)
                    .opacity(isMinimalMode ? 0 : 1)
                    .scaleEffect(isMinimalMode ? 0.95 : 1.0, anchor: .top)
                    .offset(y: isMinimalMode ? -8 : 0)
                    .blur(radius: isMinimalMode ? 3 : 0)
                    .frame(height: isMinimalMode ? 0 : nil)
                    .animation(.spring(response: springResponse, dampingFraction: springDamping).delay(0.06), value: isMinimalMode)

                Divider()
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .opacity(isMinimalMode ? 0 : 1)
                    .frame(height: isMinimalMode ? 0 : nil)
                    .animation(.spring(response: springResponse, dampingFraction: springDamping).delay(0.07), value: isMinimalMode)

                // Footer - staggered animation
                PanelFooterView(showingStatistics: $showingStatistics)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .padding(.bottom, 8)
                    .opacity(isMinimalMode ? 0 : 1)
                    .scaleEffect(isMinimalMode ? 0.95 : 1.0, anchor: .top)
                    .offset(y: isMinimalMode ? -8 : 0)
                    .blur(radius: isMinimalMode ? 3 : 0)
                    .frame(height: isMinimalMode ? 0 : nil)
                    .animation(.spring(response: springResponse, dampingFraction: springDamping).delay(0.08), value: isMinimalMode)
            }
            .frame(width: geo.size.width, alignment: .top)
        }
        .modifier(AnimatedLiquidGlassBackground(isVisible: !isMinimalMode, springResponse: backgroundSpringResponse, springDamping: backgroundSpringDamping))
    }

    private var minimalView: some View {
        // Minimal mode: transparent background, only shows timer ring and time
        GeometryReader { geo in
            VStack(spacing: 0) {
                // Timer area with fixed position
                VStack(spacing: 12) {
                    // Session label
                    sessionLabel
                        .opacity(0)
                        .frame(height: 0)

                    // Timer ring - FIXED SIZE AND POSITION with matched geometry
                    ZStack {
                        TimerRingView(showCurrentTime: true, currentTimeString: currentTimeString)
                            .frame(width: timerRingSize, height: timerRingSize)
                            .contentShape(Circle())
                            .matchedGeometryEffect(id: "timerRing", in: timerNamespace)
                            .onTapGesture {
                                withAnimation(.spring(response: springResponse, dampingFraction: springDamping)) {
                                    isMinimalMode.toggle()
                                }
                            }
                    }
                    .frame(height: timerRingSize)

                    // Cycle indicator
                    cycleIndicator
                        .opacity(0)
                        .frame(height: 0)
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)

                // Controls
                TimerControlsView()
                    .padding(.top, 16)
                    .padding(.horizontal, 20)
                    .opacity(0)
                    .frame(height: 0)

                Divider()
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .opacity(0)
                    .frame(height: 0)

                // Quick stats
                QuickStatsView()
                    .padding(.top, 12)
                    .padding(.horizontal, 20)
                    .opacity(0)
                    .frame(height: 0)

                Divider()
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .opacity(0)
                    .frame(height: 0)

                // Footer
                PanelFooterView(showingStatistics: $showingStatistics)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .opacity(0)
                    .frame(height: 0)

                Spacer()
            }
            .frame(width: geo.size.width)
        }
        .background(.clear)
    }

    private var sessionLabel: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(sessionColor)
                .frame(width: 8, height: 8)

            Text(pomodoroManager.currentSession.localizedName)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }

    private var cycleIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<pomodoroManager.sessionsPerCycle, id: \.self) { index in
                Circle()
                    .fill(
                        index < pomodoroManager.completedSessionsInCycle
                            ? appSettings.accentColor
                            : Color.primary.opacity(0.15)
                    )
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.3), value: pomodoroManager.completedSessionsInCycle)
            }
        }
    }

    private var sessionColor: Color {
        switch pomodoroManager.currentSession {
        case .focus: return appSettings.accentColor
        case .shortBreak, .longBreak: return .green
        }
    }

    private var currentTimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
}
