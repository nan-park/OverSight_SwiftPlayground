import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: TodayViewModel?
    @State private var reflectionText: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    questionSection

                    photoSection

                    reflectionSection
                }
                .padding(Spacing.lg)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("오늘")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: ArchiveView()) {
                        Image(systemName: "archivebox")
                    }
                }
            }
            .onAppear {
                setupViewModel()
            }
        }
    }

    // MARK: - Sections

    private var questionSection: some View {
        Group {
            if let viewModel {
                Text(viewModel.todayQuestion)
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
            } else {
                ProgressView()
            }
        }
    }

    private var photoSection: some View {
        PhotoAnswerArea(
            photoData: viewModel?.todayEntry?.photoData
        ) {
            handlePhotoTap()
        }
    }

    private var reflectionSection: some View {
        ReflectionEditor(text: $reflectionText)
            .onChange(of: reflectionText) { _, newValue in
                viewModel?.todayEntry?.reflection = newValue
            }
    }

    // MARK: - Actions

    private func setupViewModel() {
        if viewModel == nil {
            viewModel = TodayViewModel(
                repository: EntryRepository(modelContext: modelContext)
            )
        }
        viewModel?.loadTodayEntry()

        if let entry = viewModel?.todayEntry {
            reflectionText = entry.reflection
        }
    }

    private func handlePhotoTap() {
        // TODO: Open camera/photo picker
    }
}

#Preview {
    TodayView()
        .modelContainer(for: Entry.self, inMemory: true)
}
