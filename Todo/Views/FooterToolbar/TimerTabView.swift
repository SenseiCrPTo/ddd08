import SwiftUI

struct TimerTabView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("⏱ Таймер")
                    .font(.largeTitle.bold())
                Text("Будет добавлен функционал отслеживания времени")
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationTitle("Таймер")
        }
    }
}
