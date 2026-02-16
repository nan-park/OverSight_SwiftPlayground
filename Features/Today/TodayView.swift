import SwiftUI

struct TodayView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.md) {
                Spacer()

                Image(systemName: "eyes")
                    .font(.system(size: 64))
                    .foregroundStyle(.secondary)

                Text("OverSight")
                    .font(.displayLarge)

                Text("오늘의 기록을 시작하세요")
                    .font(.bodyLarge)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding(Spacing.lg)
            .navigationTitle("오늘")
        }
    }
}

#Preview {
    TodayView()
}
