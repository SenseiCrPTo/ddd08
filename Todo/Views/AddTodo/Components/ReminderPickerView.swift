import SwiftUI

struct ReminderPickerView: View {
    var viewModel: TodoAddViewModel

    var body: some View {
        Section(header: Text("Напоминание")) {
            Toggle("Установить напоминание", isOn: .constant(false))
                .disabled(true)
        }
    }
}
