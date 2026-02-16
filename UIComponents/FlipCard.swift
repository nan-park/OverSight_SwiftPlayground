import SwiftUI

struct FlipCard<Front: View, Back: View>: View {
    @Binding var isFlipped: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let front: Front
    let back: Back

    init(
        isFlipped: Binding<Bool>,
        @ViewBuilder front: () -> Front,
        @ViewBuilder back: () -> Back
    ) {
        self._isFlipped = isFlipped
        self.front = front()
        self.back = back()
    }

    var body: some View {
        Group {
            if reduceMotion {
                fadeTransition
            } else {
                flipTransition
            }
        }
        .onTapGesture {
            withAnimation(reduceMotion ? .easeInOut(duration: 0.3) : .spring(duration: 0.5)) {
                isFlipped.toggle()
            }
        }
    }

    private var fadeTransition: some View {
        ZStack {
            front
                .opacity(isFlipped ? 0 : 1)
            back
                .opacity(isFlipped ? 1 : 0)
        }
    }

    private var flipTransition: some View {
        ZStack {
            front
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )

            back
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -180),
                    axis: (x: 0, y: 1, z: 0)
                )
        }
    }
}
