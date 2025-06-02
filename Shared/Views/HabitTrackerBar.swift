// Shared/Views/HabitTrackerBar.swift
import SwiftUI

struct HabitTrackerBar: View {
    let daysDone: Int
    let totalDays: Int // Обычно 7 для недели
    let activeColor: Color
    let inactiveColor: Color = Color.gray.opacity(0.3) // Цвет для невыполненных дней
    let circleSize: CGFloat = 10 // Размер кружков
    let spacing: CGFloat = 4     // Расстояние между кружками

    var body: some View {
        HStack(spacing: spacing) {
            if totalDays > 0 { // Защита от деления на ноль или отрицательных значений
                ForEach(0..<totalDays, id: \.self) { index in
                    Circle()
                        .fill(index < daysDone ? activeColor : inactiveColor)
                        .frame(width: circleSize, height: circleSize)
                }
            } else {
                Text("N/A") // Или другое отображение, если totalDays некорректен
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct HabitTrackerBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            HabitTrackerBar(daysDone: 3, totalDays: 7, activeColor: .blue)
            HabitTrackerBar(daysDone: 7, totalDays: 7, activeColor: .green)
            HabitTrackerBar(daysDone: 0, totalDays: 7, activeColor: .orange)
            HabitTrackerBar(daysDone: 5, totalDays: 5, activeColor: .purple)
            HabitTrackerBar(daysDone: 2, totalDays: 0, activeColor: .red) // Тест некорректного totalDays
        }
        .padding()
    }
}
