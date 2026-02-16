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
        VStack(spacing: Spacing.lg) {
            Spacer()

            // Card stack
            ZStack {
                // Background cards (stack effect)
                ForEach(0..<min(3, entries.count - currentIndex), id: \.self) { offset in
                    let index = currentIndex + offset
                    if index < entries.count && offset > 0 {
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.white)
                            .aspectRatio(3/4, contentMode: .fit)
                            .frame(maxHeight: 420)
                            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                            .offset(x: CGFloat(offset) * 6, y: CGFloat(offset) * 6)
                            .scaleEffect(1 - CGFloat(offset) * 0.03)
                    }
                }

                // Current card
                ArchiveCardView(entry: entries[currentIndex])
                    .id(currentIndex)
                    .aspectRatio(3/4, contentMode: .fit)
                    .frame(maxHeight: 420)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            }
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

            Spacer()

            // Page indicator
            Text("\(currentIndex + 1) / \(entries.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, Spacing.lg)
        }
        .padding(.horizontal, Spacing.xl)
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

// MARK: - Preview with Sample Data

#Preview {
    struct PreviewWrapper: View {
        @State private var container: ModelContainer?

        var body: some View {
            NavigationStack {
                if container != nil {
                    ArchiveView()
                } else {
                    ProgressView()
                }
            }
            .modelContainer(for: Entry.self, inMemory: true) { result in
                if case .success(let container) = result {
                    let context = container.mainContext

                    // Sample entries
                    let entries = [
                        Entry(day: Date(), question: "What feels the most alive at this moment?", reflection: "The morning light."),
                        Entry(day: Date().addingTimeInterval(-86400), question: "What seems out of place in this space?", reflection: "An old book on the shelf."),
                        Entry(day: Date().addingTimeInterval(-86400 * 2), question: "What looks like it's holding something together?", reflection: "The tape on the window."),
                        Entry(day: Date().addingTimeInterval(-86400 * 3), question: "What appears to be waiting?", reflection: "My coffee cup.")
                    ]

                    for entry in entries {
                        context.insert(entry)
                    }

                    self.container = container
                }
            }
        }
    }
    return PreviewWrapper()
}
