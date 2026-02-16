import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: TodayViewModel?

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.lg) {
                Spacer()

                if let viewModel {
                    Text(viewModel.todayQuestion)
                        .font(.displayMedium)
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                } else {
                    ProgressView()
                }

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
            .onAppear {
                if viewModel == nil {
                    viewModel = TodayViewModel(
                        repository: EntryRepository(modelContext: modelContext)
                    )
                }
                viewModel?.loadTodayEntry()
            }
        }
    }

    #if DEBUG
    @State private var debugMessage: String = ""

    private var debugSection: some View {
        VStack(spacing: Spacing.sm) {
            if let entry = viewModel?.todayEntry {
                Text("Entry exists: \(entry.question)")
                    .font(.caption)
                    .foregroundStyle(.green)
            }

            Text(debugMessage)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: Spacing.sm) {
                Button("Create") {
                    createTestEntry()
                }
                Button("Fetch") {
                    viewModel?.loadTodayEntry()
                    debugMessage = viewModel?.todayEntry != nil ? "Entry found" : "No entry"
                }
                Button("Delete") {
                    deleteEntry()
                }
            }
            .buttonStyle(.bordered)
        }
    }

    private func createTestEntry() {
        guard let viewModel else { return }
        let entry = Entry(
            day: Date(),
            question: viewModel.todayQuestion,
            reflection: "테스트 회고"
        )
        let repo = EntryRepository(modelContext: modelContext)
        do {
            try repo.upsert(entry)
            viewModel.loadTodayEntry()
            debugMessage = "Created entry"
        } catch {
            debugMessage = "Error: \(error.localizedDescription)"
        }
    }

    private func deleteEntry() {
        let repo = EntryRepository(modelContext: modelContext)
        do {
            try repo.delete(for: Date())
            viewModel?.loadTodayEntry()
            debugMessage = "Deleted entry"
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
