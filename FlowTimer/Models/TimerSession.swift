import Foundation

struct TimerSession: Identifiable, Codable, Equatable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let durationMinutes: Int
    let type: SessionType
    let completed: Bool

    enum SessionType: String, Codable {
        case focus
        case shortBreak
        case longBreak
    }

    init(
        id: UUID = UUID(),
        startDate: Date,
        endDate: Date,
        durationMinutes: Int,
        type: SessionType,
        completed: Bool
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.durationMinutes = durationMinutes
        self.type = type
        self.completed = completed
    }

    var durationSeconds: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
}
