import SwiftUI

struct TodoToolbarItems: View {
    var body: some View {
        Group {
            Button(action: {
                print("Открыть события")
            }) {
                Image(systemName: "globe")
            }

            Button(action: {
                print("Открыть поиск")
            }) {
                Image(systemName: "magnifyingglass")
            }

            Button(action: {
                print("Открыть фильтр")
            }) {
                Image(systemName: "line.3.horizontal.decrease.circle")
            }

            Button(action: {
                print("Открыть настройки")
            }) {
                Image(systemName: "gearshape")
            }
        }
    }
}
