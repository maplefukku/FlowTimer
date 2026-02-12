import SwiftUI
import Charts
import UniformTypeIdentifiers

/// Statistics dashboard with charts and data export.
struct StatisticsView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @State private var selectedTab = 0
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(NSLocalizedString("statistics.title", comment: "Statistics"))
                    .font(.system(size: 18, weight: .semibold))

                Spacer()

                Menu {
                    Button(NSLocalizedString("statistics.exportCSV", comment: "Export CSV")) {
                        exportCSV()
                    }
                    Button(NSLocalizedString("statistics.exportJSON", comment: "Export JSON")) {
                        exportJSON()
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 13))
                }
                .menuStyle(.borderlessButton)
                .frame(width: 30)

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)

            // Summary cards
            summaryCards
                .padding(.horizontal, 20)

            Divider()
                .padding(.vertical, 12)

            // Tab selector
            Picker("", selection: $selectedTab) {
                Text(NSLocalizedString("statistics.week", comment: "Week")).tag(0)
                Text(NSLocalizedString("statistics.month", comment: "Month")).tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)

            // Chart
            if selectedTab == 0 {
                weeklyChart
                    .padding(20)
            } else {
                monthlyChart
                    .padding(20)
            }

            Spacer()
        }
        .frame(minWidth: 500, minHeight: 400)
    }

    // MARK: - Summary Cards

    private var summaryCards: some View {
        HStack(spacing: 12) {
            summaryCard(
                icon: "checkmark.circle",
                value: "\(sessionStore.todaySessionCount)",
                label: NSLocalizedString("stats.todaySessions", comment: "Today"),
                color: .blue
            )

            summaryCard(
                icon: "clock",
                value: formatMinutes(sessionStore.todayFocusMinutes),
                label: NSLocalizedString("stats.todayFocus", comment: "Focus Time"),
                color: .green
            )

            summaryCard(
                icon: "flame",
                value: "\(sessionStore.currentStreak)",
                label: NSLocalizedString("stats.dayStreak", comment: "Day Streak"),
                color: .orange
            )

            summaryCard(
                icon: "sum",
                value: "\(sessionStore.sessions.filter { $0.type == .focus && $0.completed }.count)",
                label: NSLocalizedString("stats.total", comment: "Total"),
                color: .purple
            )
        }
    }

    private func summaryCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .monospaced))

            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.06))
        )
    }

    // MARK: - Charts

    @ViewBuilder
    private var weeklyChart: some View {
        let data = sessionStore.last7Days()

        if #available(macOS 14.0, *) {
            Chart {
                ForEach(data, id: \.date) { item in
                    BarMark(
                        x: .value("Day", item.date, unit: .day),
                        y: .value("Minutes", item.minutes)
                    )
                    .foregroundStyle(Color.accentColor.gradient)
                    .cornerRadius(4)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let minutes = value.as(Int.self) {
                            Text("\(minutes)m")
                                .font(.caption2)
                        }
                    }
                }
            }
        } else {
            // Fallback simple bar visualization
            simpleBarChart(data: data)
        }
    }

    @ViewBuilder
    private var monthlyChart: some View {
        let data = sessionStore.last30Days()

        if #available(macOS 14.0, *) {
            Chart {
                ForEach(data, id: \.date) { item in
                    BarMark(
                        x: .value("Day", item.date, unit: .day),
                        y: .value("Minutes", item.minutes)
                    )
                    .foregroundStyle(Color.accentColor.gradient)
                    .cornerRadius(2)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .weekOfYear)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                }
            }
        } else {
            simpleBarChart(data: data)
        }
    }

    private func simpleBarChart(data: [(date: Date, minutes: Int)]) -> some View {
        let maxMinutes = max(data.map(\.minutes).max() ?? 1, 1)

        return HStack(alignment: .bottom, spacing: 2) {
            ForEach(data, id: \.date) { item in
                VStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.accentColor)
                        .frame(
                            width: max(4, 400 / CGFloat(data.count) - 4),
                            height: max(2, CGFloat(item.minutes) / CGFloat(maxMinutes) * 150)
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Export

    private func exportCSV() {
        let csv = sessionStore.exportCSV()
        saveFile(content: csv, filename: "flowtimer-sessions.csv", type: "csv")
    }

    private func exportJSON() {
        guard let data = sessionStore.exportJSON() else { return }
        saveFile(data: data, filename: "flowtimer-sessions.json", type: "json")
    }

    private func saveFile(content: String, filename: String, type: String) {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = filename
        panel.allowedContentTypes = [.plainText]
        panel.begin { response in
            if response == .OK, let url = panel.url {
                try? content.write(to: url, atomically: true, encoding: .utf8)
            }
        }
    }

    private func saveFile(data: Data, filename: String, type: String) {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = filename
        panel.allowedContentTypes = [.json]
        panel.begin { response in
            if response == .OK, let url = panel.url {
                try? data.write(to: url)
            }
        }
    }

    private func formatMinutes(_ minutes: Int) -> String {
        if minutes >= 60 {
            let h = minutes / 60
            let m = minutes % 60
            return m > 0 ? "\(h)h\(m)m" : "\(h)h"
        }
        return "\(minutes)m"
    }
}
