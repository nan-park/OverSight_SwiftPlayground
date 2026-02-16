import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: TodayViewModel?
    @State private var reflectionText: String = ""
    @State private var showCamera = false
    @State private var showConfirm = false
    @State private var showPermissionAlert = false
    @State private var pendingPhotoData: Data?

    private let cameraService = CameraService.shared

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
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
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
            .fullScreenCover(isPresented: $showCamera) {
                CameraPicker { data in
                    if let data {
                        pendingPhotoData = data
                        showConfirm = true
                    }
                }
                .ignoresSafeArea()
            }
            .fullScreenCover(isPresented: $showConfirm) {
                if let photoData = pendingPhotoData, let viewModel {
                    ConfirmView(
                        photoData: photoData,
                        question: viewModel.todayQuestion,
                        hasExistingTodayPhoto: viewModel.todayEntry?.photoData != nil,
                        existingReflection: viewModel.todayEntry?.reflection ?? "",
                        onRetake: {
                            showConfirm = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showCamera = true
                            }
                        },
                        onSaved: {
                            reloadEntry()
                        }
                    )
                }
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
            handlePhotoTap()
        }
    }

    private var reflectionSection: some View {
        ReflectionEditor(text: $reflectionText)
            .onChange(of: reflectionText) { _, newValue in
                updateReflection(newValue)
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
        syncReflectionText()
    }

    private func reloadEntry() {
        viewModel?.loadTodayEntry()
        syncReflectionText()
        pendingPhotoData = nil
    }

    private func syncReflectionText() {
        if let entry = viewModel?.todayEntry {
            reflectionText = entry.reflection
        } else {
            reflectionText = ""
        }
    }

    private func updateReflection(_ newValue: String) {
        guard let entry = viewModel?.todayEntry else { return }
        entry.reflection = newValue
        entry.updatedAt = Date()
        try? modelContext.save()
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
