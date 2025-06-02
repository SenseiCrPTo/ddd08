import SwiftUI

struct SubtaskListView: View {
    @Binding var subtasks: [Subtask]
    let addSubtask: () -> Void
    let removeSubtask: (Int) -> Void
    let moveSubtask: (IndexSet, Int) -> Void

    var body: some View {
        Section(header: Text("Подзадачи")) {
            ForEach(subtasks.indices, id: \.self) { index in
                HStack {
                    Button(action: {
                        subtasks[index].isCompleted.toggle()
                    }) {
                        Image(systemName: subtasks[index].isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(subtasks[index].isCompleted ? .green : .gray)
                    }

                    TextField("Подзадача", text: $subtasks[index].title)

                    Spacer()

                    Button(action: {
                        removeSubtask(index)
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .onMove(perform: moveSubtask)

            Button(action: {
                addSubtask()
            }) {
                Label("Добавить подзадачу", systemImage: "plus.circle")
            }
        }
    }
}
