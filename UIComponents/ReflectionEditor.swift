import SwiftUI

struct ReflectionEditor: View {
    @Binding var text: String
    var placeholder: String = "Because…"

    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty && !isFocused {
                Text(placeholder)
                    .font(.bodyLarge)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, Spacing.xs)
                    .padding(.vertical, Spacing.sm)
            }

            TextEditor(text: $text)
                .font(.bodyLarge)
                .focused($isFocused)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .frame(minHeight: 80)
        }
        .padding(Spacing.sm)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        .accessibilityLabel("Reflection")
        .accessibilityHint("Write your thoughts about the photo")
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var text = ""
        var body: some View {
            ReflectionEditor(text: $text)
                .padding()
        }
    }
    return PreviewWrapper()
}
