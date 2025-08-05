import SwiftUI
import SwiftData

struct MoodHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    // @Query automatically fetches and sorts the data, and updates the view on changes.
    @Query(sort: \MoodLog.date, order: .reverse) private var moodLogs: [MoodLog]
    
    var body: some View {
        List {
            if moodLogs.isEmpty {
                Text("No moods logged yet.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(moodLogs) { log in
                    HStack {
                        Image(systemName: log.emotion.icon)
                            .font(.title2)
                            .foregroundColor(log.emotion.color)
                            .padding(8)
                            .background(log.emotion.color.opacity(0.2))
                            .clipShape(Circle())

                        VStack(alignment: .leading) {
                            Text(log.emotion.title)
                                .font(.headline)
                            Text(log.date.formatted(date: .long, time: .shortened))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }.onDelete(perform: deleteLog)
            }
        }
        .navigationTitle("Mood History")
        .toolbar {
            if !moodLogs.isEmpty {
                EditButton()
            }
        }
    }
    
    private func deleteLog(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(moodLogs[index])
        }
    }
}
