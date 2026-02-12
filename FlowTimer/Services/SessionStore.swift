import Foundation
import Combine

/// Persists timer sessions to disk and provides statistics.
final class SessionStore: ObservableObject {
    @Published private(set) var sessions: [TimerSession] = []

    private let fileURL: URL
    private let calendar = Calendar.current

    init() {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!.appendingPathComponent("FlowTimer", isDirectory: true)

        try? FileManager.default.createDirectory(at: appSupport, withIntermediateDirectories: true)
        fileURL = appSupport.appendingPathComponent("sessions.json")

        load()
    }

    // MARK: - CRUD

    func addSession(_ session: TimerSession) {
        sessions.append(session)
        save()
    }

    // MARK: - Today's Stats

    var todaySessionCount: Int {
        todaySessions.count
    }

    var todayFocusMinutes: Int {
        todaySessions.reduce(0) { $0 + $1.durationMinutes }
    }

    private var todaySessions: [TimerSession] {
        let startOfDay = calendar.startOfDay(for: Date())
        return sessions.filter { session in
            session.type == .focus && session.completed && session.startDate >= startOfDay
        }
    }

    // MARK: - Streak

    var currentStreak: Int {
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        // Check if today has sessions
        let todayHasSessions = sessions.contains { session in
            session.type == .focus && session.completed && calendar.isDate(session.startDate, inSameDayAs: checkDate)
        }

        if !todayHasSessions {
            // If no sessions today, start checking from yesterday
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }

        while true {
            let dayHasSessions = sessions.contains { session in
                session.type == .focus && session.completed && calendar.isDate(session.startDate, inSameDayAs: checkDate)
            }

            if dayHasSessions {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else {
                break
            }
        }

        return streak
    }

    // MARK: - Weekly Data

    func sessionsForDay(_ date: Date) -> [TimerSession] {
        sessions.filter { session in
            session.type == .focus && session.completed && calendar.isDate(session.startDate, inSameDayAs: date)
        }
    }

    func focusMinutesForDay(_ date: Date) -> Int {
        sessionsForDay(date).reduce(0) { $0 + $1.durationMinutes }
    }

    func last7Days() -> [(date: Date, minutes: Int)] {
        (0..<7).reversed().compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { return nil }
            return (date: calendar.startOfDay(for: date), minutes: focusMinutesForDay(date))
        }
    }

    func last30Days() -> [(date: Date, minutes: Int)] {
        (0..<30).reversed().compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { return nil }
            return (date: calendar.startOfDay(for: date), minutes: focusMinutesForDay(date))
        }
    }

    // MARK: - Export

    func exportCSV() -> String {
        var csv = "id,start_date,end_date,duration_minutes,type,completed\n"
        let formatter = ISO8601DateFormatter()

        for session in sessions {
            csv += "\(session.id.uuidString),"
            csv += "\(formatter.string(from: session.startDate)),"
            csv += "\(formatter.string(from: session.endDate)),"
            csv += "\(session.durationMinutes),"
            csv += "\(session.type.rawValue),"
            csv += "\(session.completed)\n"
        }

        return csv
    }

    func exportJSON() -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try? encoder.encode(sessions)
    }

    // MARK: - Persistence

    func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(sessions) {
            try? data.write(to: fileURL, options: .atomicWrite)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let loaded = try? decoder.decode([TimerSession].self, from: data) {
            sessions = loaded
        }
    }
}
