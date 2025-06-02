import SwiftUI

struct TodoTabWrapperView<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .toolbar {
                TodoHeaderToolbarView()
            }
    }
}
