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

    // MARK: - Front (Polaroid style)

    private var cardFront: some View {
        VStack(spacing: 0) {
            // Photo area
            Group {
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
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)
                        }
                }
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.top, Spacing.sm)

            // Bottom area with date
            HStack {
                Spacer()
                Text(entry.day.formatted(date: .numeric, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.md)
        }
        .background(Color.white)
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
    }

    // MARK: - Back

    private var cardBack: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text(entry.question)
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)

            if !entry.reflection.isEmpty {
                Text(entry.reflection)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            HStack {
                Spacer()
                Text(entry.day.formatted(date: .long, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white)
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
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
    .aspectRatio(3/4, contentMode: .fit)
    .frame(maxHeight: 420)
    .padding()
}
