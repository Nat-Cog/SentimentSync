import SwiftUI
import SwiftData

struct MoodHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    // @Query automatically fetches and sorts the data, and updates the view on changes.
    @Query(sort: \MoodLog.date, order: .reverse) private var moodLogs: [MoodLog]
    
    var body: some View {
        ZStack { 
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
            .scrollContentBackground(.hidden)
            .navigationTitle("Mood History")
            .onAppear(perform: loadHistory)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.85, green: 0.90, blue: 0.98), Color(red: 0.98, green: 0.90, blue: 0.95)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
            )
            .toolbar {
                if !moodLogs.isEmpty {
                    EditButton()
                }
            }
        }
    }
    
    private func deleteLog(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(moodLogs[index])
        }
    }
}
