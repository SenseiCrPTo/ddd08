import SwiftUI

struct NoteEditorView: View {
    @Binding var text: String

    var body: some View {
        Section(header: Text("Заметки")) {
            TextEditor(text: $text)
                .frame(height: 120)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
        }
    }
}
