import SwiftUI

struct ArchiveCardView: View {
    let entry: Entry
    @State private var isFlipped = false

    var body: some View {
        FlipCard(isFlipped: $isFlipped) {
            cardFront
        } back: {
            cardBack
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(isFlipped ? "Double tap to show photo" : "Double tap to reveal context")
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Front

    private var cardFront: some View {
        ZStack(alignment: .bottom) {
            if let photoData = entry.photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            } else {
                Color(.systemGray5)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.system(size: 64))
                            .foregroundStyle(.secondary)
                    }
            }

            Text("Tap to reveal context")
                .font(.caption)
                .foregroundStyle(.white)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(.bottom, Spacing.lg)
        }
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl))
    }

    // MARK: - Back

    private var cardBack: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text(entry.question)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)

            if !entry.reflection.isEmpty {
                Text(entry.reflection)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            Text(entry.day.formatted(date: .long, time: .omitted))
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl))
        .overlay {
            RoundedRectangle(cornerRadius: CornerRadius.xl)
                .stroke(Color(.systemGray4), lineWidth: 1)
        }
    }

    // MARK: - Accessibility

    private var accessibilityLabel: String {
        if isFlipped {
            var label = "Question: \(entry.question)"
            if !entry.reflection.isEmpty {
                label += ". Reflection: \(entry.reflection)"
            }
            label += ". Date: \(entry.day.formatted(date: .long, time: .omitted))"
            return label
        } else {
            return "Photo card"
        }
    }
}

#Preview {
    ArchiveCardView(entry: Entry(
        day: Date(),
        question: "What feels the most alive at this moment?",
        reflection: "The sunlight streaming through the window made everything feel warm and peaceful."
    ))
    .padding()
    .frame(height: 500)
}
