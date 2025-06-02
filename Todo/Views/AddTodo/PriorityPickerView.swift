// MARK: - PriorityPickerView.swift

import SwiftUI

struct PriorityPickerView: View {
    @Binding var priority: EisenhowerPriority

    var body: some View {
        Picker("Приоритет", selection: $priority) {
            ForEach(EisenhowerPriority.allCases) { priority in
                Text(priority.rawValue).tag(priority)
            }
        }
        .pickerStyle(.inline)
    }
}
