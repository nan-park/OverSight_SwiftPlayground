import SwiftUI

struct PhotoAnswerArea: View {
    let photoData: Data?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Group {
                if let photoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    placeholderContent
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 280)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(photoData != nil ? "Photo answer. Tap to change." : "Tap to take a photo answer")
        .accessibilityHint("Opens camera to capture your answer")
        .accessibilityAddTraits(.isButton)
    }

    private var placeholderContent: some View {
        ZStack {
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(Color(.systemGray6))

            VStack(spacing: Spacing.sm) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.secondary)

                Text("Look around.")
                    .font(.titleMedium)
                    .foregroundStyle(.primary)

                Text("Tap to answer.")
                    .font(.bodyMedium)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview("Empty") {
    PhotoAnswerArea(photoData: nil) {}
        .padding()
}
