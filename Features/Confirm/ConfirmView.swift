import SwiftUI
import SwiftData

struct ConfirmView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let photoData: Data
    let question: String
    let hasExistingTodayPhoto: Bool
    let existingReflection: String

    var onRetake: () -> Void
    var onSaved: () -> Void

    @State private var reflectionText: String = ""
    @State private var showEmptyReflectionAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    photoPreview

                    questionSection

                    reflectionSection
                }
                .padding(Spacing.lg)
            }
            .scrollDismissesKeyboard(.interactively)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationTitle("확인")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if hasExistingTodayPhoto {
                        Button("Cancel") {
                            dismiss()
                        }
                    } else {
                        Button("Retake") {
                            onRetake()
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(hasExistingTodayPhoto ? "Replace" : "Save") {
                        handleSaveTap()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                reflectionText = existingReflection
            }
            .alert(
                hasExistingTodayPhoto ? "Replace without a reflection?" : "Save without a reflection?",
                isPresented: $showEmptyReflectionAlert
            ) {
                Button("Add reflection", role: .cancel) {}
                Button(hasExistingTodayPhoto ? "Replace anyway" : "Save anyway") {
                    saveEntry()
                }
            } message: {
                Text(hasExistingTodayPhoto
                     ? "You can add a reflection anytime on the Today screen."
                     : "A short reason helps this entry stay meaningful.")
            }
        }
    }

    // MARK: - Sections

    private var photoPreview: some View {
        Group {
            if let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            }
        }
    }

    private var questionSection: some View {
        Text(question)
            .font(.title2)
            .fontWeight(.semibold)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.secondary)
    }

    private var reflectionSection: some View {
        ReflectionEditor(
            text: $reflectionText,
            placeholder: "I chose this because…"
        )
    }

    // MARK: - Actions

    private func handleSaveTap() {
        if reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showEmptyReflectionAlert = true
        } else {
            saveEntry()
        }
    }

    private func saveEntry() {
        let repository = EntryRepository(modelContext: modelContext)

        do {
            if let existing = try repository.fetch(for: Date()) {
                existing.photoData = photoData
                existing.reflection = reflectionText
                existing.updatedAt = Date()
                try modelContext.save()
            } else {
                let entry = Entry(
                    day: Date(),
                    question: question,
                    photoData: photoData,
                    reflection: reflectionText
                )
                try repository.upsert(entry)
            }
            onSaved()
            dismiss()
        } catch {
            print("Failed to save entry: \(error)")
        }
    }
}

#Preview {
    ConfirmView(
        photoData: Data(),
        question: "What feels the most alive at this moment?",
        hasExistingTodayPhoto: false,
        existingReflection: "",
        onRetake: {},
        onSaved: {}
    )
    .modelContainer(for: Entry.self, inMemory: true)
}
