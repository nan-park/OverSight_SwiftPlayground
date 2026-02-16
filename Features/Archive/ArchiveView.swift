import SwiftUI
import SwiftData

struct ArchiveView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ArchiveViewModel?
    @State private var currentIndex: Int = 0

    var body: some View {
        Group {
            if let viewModel {
                if viewModel.entries.isEmpty {
                    emptyState
                } else {
                    cardStack(viewModel.entries)
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

    private func cardStack(_ entries: [Entry]) -> some View {
        VStack(spacing: Spacing.md) {
            // Card
            ArchiveCardView(entry: entries[currentIndex])
                .id(currentIndex)
                .gesture(
                    DragGesture(minimumDistance: 50)
                        .onEnded { value in
                            let horizontal = value.translation.width
                            if horizontal < -50 && currentIndex < entries.count - 1 {
                                withAnimation(.spring(duration: 0.3)) {
                                    currentIndex += 1
                                }
                            } else if horizontal > 50 && currentIndex > 0 {
                                withAnimation(.spring(duration: 0.3)) {
                                    currentIndex -= 1
                                }
                            }
                        }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

            // Page indicator
            HStack(spacing: Spacing.xs) {
                Text("\(currentIndex + 1) / \(entries.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, Spacing.md)
        }
        .padding(.horizontal, Spacing.lg)
    }

    // MARK: - Actions

    private func setupViewModel() {
        if viewModel == nil {
            viewModel = ArchiveViewModel(
                repository: EntryRepository(modelContext: modelContext)
            )
        }
        viewModel?.loadEntries()
        currentIndex = 0
    }
}

#Preview {
    NavigationStack {
        ArchiveView()
    }
    .modelContainer(for: Entry.self, inMemory: true)
}
