import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var entries: [Entry] = []
    @State private var debugMessage: String = ""

    private var repository: EntryRepository {
        EntryRepository(modelContext: modelContext)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.md) {
                Spacer()

                Image(systemName: "eyes")
                    .font(.system(size: 64))
                    .foregroundStyle(.secondary)

                Text("OverSight")
                    .font(.displayLarge)

                Text("오늘의 기록을 시작하세요")
                    .font(.bodyLarge)
                    .foregroundStyle(.secondary)

                Spacer()

                #if DEBUG
                debugSection
                #endif
            }
            .padding(Spacing.lg)
            .navigationTitle("오늘")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: ArchiveView()) {
                        Image(systemName: "archivebox")
                    }
                }
            }
        }
    }

    #if DEBUG
    private var debugSection: some View {
        VStack(spacing: Spacing.sm) {
            Text(debugMessage)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: Spacing.sm) {
                Button("Create") {
                    createTestEntry()
                }
                Button("Fetch") {
                    fetchEntries()
                }
                Button("Delete") {
                    deleteLatestEntry()
                }
            }
            .buttonStyle(.bordered)
        }
    }

    private func createTestEntry() {
        let entry = Entry(
            day: Date(),
            question: "테스트 질문",
            reflection: "테스트 회고"
        )
        do {
            try repository.upsert(entry)
            debugMessage = "Created entry for \(entry.day.formatted(date: .abbreviated, time: .omitted))"
        } catch {
            debugMessage = "Error: \(error.localizedDescription)"
        }
    }

    private func fetchEntries() {
        do {
            entries = try repository.fetchAll()
            debugMessage = "Fetched \(entries.count) entries"
        } catch {
            debugMessage = "Error: \(error.localizedDescription)"
        }
    }

    private func deleteLatestEntry() {
        do {
            if let latest = try repository.fetchAll().first {
                try repository.delete(latest)
                debugMessage = "Deleted entry"
            } else {
                debugMessage = "No entries to delete"
            }
        } catch {
            debugMessage = "Error: \(error.localizedDescription)"
        }
    }
    #endif
}

#Preview {
    TodayView()
        .modelContainer(for: Entry.self, inMemory: true)
}
