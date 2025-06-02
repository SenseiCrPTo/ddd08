import SwiftUI

struct AttachmentPickerView: View {
    var viewModel: TodoAddViewModel

    var body: some View {
        Section(header: Text("Вложения")) {
            Text("Добавление файлов и изображений в разработке")
                .foregroundColor(.secondary)
        }
    }
}
