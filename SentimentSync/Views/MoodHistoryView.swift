import SwiftUI

struct MoodHistoryView: View {
    @State private var moodLogs: [MoodLog] = []

    var body: some View {
        NavigationView {
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
                                Text(log.date, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }.onDelete(perform: deleteLog)
                }
            }
            .navigationTitle("Mood History")
            .onAppear(perform: loadHistory)
            .toolbar {
                if !moodLogs.isEmpty {
                    EditButton()
                }
            }
        }
    }

    private func loadHistory() {
        moodLogs = PersistenceManager.shared.fetchMoodLogs()
    }

    private func deleteLog(at offsets: IndexSet) {
        // First, remove from the persistent storage
        PersistenceManager.shared.deleteMoodLogs(at: offsets)

        // Then, remove from the local state to update the UI
        moodLogs.remove(atOffsets: offsets)
    }
}