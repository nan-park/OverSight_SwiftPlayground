import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: TodayViewModel?
    @State private var reflectionText: String = ""
    @AppStorage("draftReflection") private var draftReflection: String = ""
    @State private var showCamera = false
    @State private var showPermissionAlert = false
    @FocusState private var isEditorFocused: Bool

    private let cameraService = CameraService.shared

    private var hasEntry: Bool {
        viewModel?.todayEntry != nil
    }

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
            .onTapGesture {
                finishEditing()
            }
            .navigationTitle("오늘")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: ArchiveView()) {
                        Image(systemName: "archivebox")
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        finishEditing()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                setupViewModel()
            }
            .onChange(of: isEditorFocused) { _, focused in
                if !focused {
                    saveReflection()
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPicker { data in
                    if let data {
                        savePhoto(data)
                    }
                }
                .ignoresSafeArea()
            }
            .alert("Camera Access Required", isPresented: $showPermissionAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please allow camera access in Settings to take photos.")
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
            if isEditorFocused {
                finishEditing()
            } else {
                handlePhotoTap()
            }
        }
    }

    private var reflectionSection: some View {
        ReflectionEditor(text: $reflectionText, isFocused: $isEditorFocused)
    }

    // MARK: - Actions

    private func setupViewModel() {
        if viewModel == nil {
            viewModel = TodayViewModel(
                repository: EntryRepository(modelContext: modelContext)
            )
        }
        viewModel?.loadTodayEntry()
        loadReflectionText()
    }

    private func loadReflectionText() {
        if let entry = viewModel?.todayEntry {
            reflectionText = entry.reflection
        } else {
            reflectionText = draftReflection
        }
    }

    private func finishEditing() {
        isEditorFocused = false
    }

    private func saveReflection() {
        if let entry = viewModel?.todayEntry {
            entry.reflection = reflectionText
            entry.updatedAt = Date()
            try? modelContext.save()
        } else {
            draftReflection = reflectionText
        }
    }

    private func savePhoto(_ photoData: Data) {
        guard let viewModel else { return }
        let repository = EntryRepository(modelContext: modelContext)

        do {
            if let existing = try repository.fetch(for: Date()) {
                existing.photoData = photoData
                existing.updatedAt = Date()
                try modelContext.save()
            } else {
                let entry = Entry(
                    day: Date(),
                    question: viewModel.todayQuestion,
                    photoData: photoData,
                    reflection: draftReflection
                )
                try repository.upsert(entry)
                draftReflection = ""
            }
            viewModel.loadTodayEntry()
            loadReflectionText()
        } catch {
            print("Failed to save photo: \(error)")
        }
    }

    private func handlePhotoTap() {
        guard cameraService.isCameraAvailable else { return }

        Task {
            switch cameraService.permissionStatus {
            case .authorized:
                showCamera = true
            case .notDetermined:
                let status = await cameraService.requestPermission()
                if status == .authorized {
                    showCamera = true
                }
            case .denied, .restricted:
                showPermissionAlert = true
            }
        }
    }
}

#Preview {
    TodayView()
        .modelContainer(for: Entry.self, inMemory: true)
}
