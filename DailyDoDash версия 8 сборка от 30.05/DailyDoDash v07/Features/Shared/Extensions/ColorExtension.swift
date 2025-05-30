// Shared/Extensions/ColorExtension.swift
import SwiftUI

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 { // RRGGBB
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 { // RRGGBBAA
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }
        self.init(.sRGB, red: Double(r), green: Double(g), blue: Double(b), opacity: Double(a))
    }

    func toHex(includeAlpha: Bool = false) -> String? {
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        // Пытаемся получить RGBA компоненты
        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) else {
            // Если не удалось получить RGBA (например, это pattern color),
            // попробуем получить только RGB, если это возможно (для цветов без альфы)
            // или вернем nil, если цвет не может быть представлен в RGB.
            // Для системных цветов типа .primary, .secondary, это может быть сложнее.
            // В таком случае, можно попробовать преобразовать в конкретное цветовое пространство,
            // но для простоты, если getRed не сработал, считаем, что HEX не получить.
            
            // Попытка для цветов без альфа-канала, если getRed с альфой не сработал
            if uiColor.getRed(&r, green: &g, blue: &b, alpha: nil) { // alpha: nil
                 let redInt = Int(min(max(0, r), 1) * 255.0)
                 let greenInt = Int(min(max(0, g), 1) * 255.0)
                 let blueInt = Int(min(max(0, b), 1) * 255.0)
                 return String(format: "#%02X%02X%02X", redInt, greenInt, blueInt)
            }
            return nil
        }

        let redInt = Int(min(max(0, r), 1) * 255.0)
        let greenInt = Int(min(max(0, g), 1) * 255.0)
        let blueInt = Int(min(max(0, b), 1) * 255.0)

        if includeAlpha {
            let alphaInt = Int(min(max(0, a), 1) * 255.0)
            return String(format: "#%02X%02X%02X%02X", redInt, greenInt, blueInt, alphaInt)
        } else {
            return String(format: "#%02X%02X%02X", redInt, greenInt, blueInt)
        }
    }
}
