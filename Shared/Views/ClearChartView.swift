// Shared/Views/ClearChartView.swift
import SwiftUI
import Charts

struct ClearChartView: View {
    let data: [MonthlyDataPoint]
    var xAxisLabel: String = "Период"

    private func foregroundColor(for type: String) -> Color {
        switch type {
        case "Доход":
            return .green
        case "Расход":
            return .red
        case "Накопления":
            return .blue
        default:
            return .gray
        }
    }

    var body: some View {
        let hasMeaningfulData = data.contains { $0.value > 0 }

        if !hasMeaningfulData {
            Text("Нет данных для графика за выбранный период.")
                .font(.caption)
                .foregroundColor(.gray)
                .frame(minHeight: 150, alignment: .center)
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            Chart {
                ForEach(data) { dataPoint in
                    if dataPoint.value > 0 {
                        LineMark(
                            x: .value(xAxisLabel, dataPoint.month),
                            y: .value("Сумма", dataPoint.value),
                            series: .value("Тип", dataPoint.type)
                        )
                        .foregroundStyle(foregroundColor(for: dataPoint.type))

                        PointMark(
                            x: .value(xAxisLabel, dataPoint.month),
                            y: .value("Сумма", dataPoint.value)
                        )
                        .foregroundStyle(foregroundColor(for: dataPoint.type))
                        .symbolSize(50)
                    }
                }
            }
            .frame(height: 150)
            .chartXAxis {
                // Используем removingDuplicates()
                let uniqueXValues = data.map { $0.month }.removingDuplicates().sorted() // <--- Убедитесь, что это расширение доступно
                
                AxisMarks(values: uniqueXValues) { value in // Передаем массив строк
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(value.as(String.self) ?? "", // value.as(String.self) должно работать для строк
                                   orientation: uniqueXValues.count > 7 ? .vertical : .horizontal)
                }
            }
            .chartYAxis {
                AxisMarks(preset: .aligned, values: .automatic(desiredCount: 4))
            }
        }
    }
}

struct ClearChartView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleData: [MonthlyDataPoint] = [
            MonthlyDataPoint(month: "Пн", date: Date(), value: 150, type: "Доход"),
            MonthlyDataPoint(month: "Пн", date: Date(), value: 80, type: "Расход"),
            MonthlyDataPoint(month: "Вт", date: Date(), value: 200, type: "Доход"),
            MonthlyDataPoint(month: "Вт", date: Date(), value: 120, type: "Расход"),
            MonthlyDataPoint(month: "Ср", date: Date(), value: 0, type: "Накопления"),
            MonthlyDataPoint(month: "Чт", date: Date(), value: 180, type: "Доход"),
            MonthlyDataPoint(month: "Чт", date: Date(), value: 90, type: "Расход"),
            MonthlyDataPoint(month: "Чт", date: Date(), value: 50, type: "Накопления"),
        ]
        
        let emptyData: [MonthlyDataPoint] = []
        let zeroValueData: [MonthlyDataPoint] = [MonthlyDataPoint(month: "Пт", date: Date(), value: 0, type: "Доход")]

        return ScrollView {
            VStack(spacing: 30) {
                Text("График с данными:")
                ClearChartView(data: sampleData, xAxisLabel: "День недели")
                    .padding()

                Text("График без данных:")
                ClearChartView(data: emptyData, xAxisLabel: "День недели")
                    .padding()
                
                Text("График только с нулевыми данными:")
                ClearChartView(data: zeroValueData, xAxisLabel: "День недели")
                    .padding()
            }
        }
    }
}
