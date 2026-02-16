import SwiftUI

struct ReflectionEditor: View {
    @Binding var text: String
    var placeholder: String = "Because…"
    var isFocused: FocusState<Bool>.Binding

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty && !isFocused.wrappedValue {
                Text(placeholder)
                    .font(.bodyLarge)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, Spacing.xs)
                    .padding(.vertical, Spacing.sm)
            }

            TextEditor(text: $text)
                .font(.bodyLarge)
                .focused(isFocused)
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
        @FocusState var focused: Bool
        var body: some View {
            ReflectionEditor(text: $text, isFocused: $focused)
                .padding()
        }
    }
    return PreviewWrapper()
}
