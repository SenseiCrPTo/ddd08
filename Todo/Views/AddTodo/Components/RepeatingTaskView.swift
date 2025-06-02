import SwiftUI

struct RepeatingTaskView: View {
    var viewModel: TodoAddViewModel

    var body: some View {
        Section(header: Text("Повтор")) {
            Text("Настройка повторов будет добавлена позже")
                .foregroundColor(.secondary)
        }
    }
}
