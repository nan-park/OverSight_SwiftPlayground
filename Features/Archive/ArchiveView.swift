import SwiftUI
import SwiftData

struct ArchiveView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ArchiveViewModel?

    var body: some View {
        Group {
            if let viewModel {
                if viewModel.entries.isEmpty {
                    emptyState
                } else {
                    entryList(viewModel.entries)
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Archive")
        .onAppear {
            setupViewModel()
        }
    }

    // MARK: - Views

    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "archivebox")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No entries yet")
                .font(.titleMedium)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func entryList(_ entries: [Entry]) -> some View {
        List(entries) { entry in
            EntryRow(entry: entry)
        }
        .listStyle(.plain)
    }

    // MARK: - Actions

    private func setupViewModel() {
        if viewModel == nil {
            viewModel = ArchiveViewModel(
                repository: EntryRepository(modelContext: modelContext)
            )
        }
        viewModel?.loadEntries()
    }
}

// MARK: - Entry Row

struct EntryRow: View {
    let entry: Entry

    var body: some View {
        HStack(spacing: Spacing.md) {
            thumbnail

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(entry.question)
                    .font(.bodyMedium)
                    .lineLimit(1)

                Text(entry.day.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, Spacing.xs)
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let photoData = entry.photoData, let uiImage = UIImage(data: photoData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
        } else {
            RoundedRectangle(cornerRadius: CornerRadius.sm)
                .fill(Color(.systemGray5))
                .frame(width: 56, height: 56)
                .overlay {
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                }
        }
    }
}

#Preview {
    NavigationStack {
        ArchiveView()
    }
    .modelContainer(for: Entry.self, inMemory: true)
}
