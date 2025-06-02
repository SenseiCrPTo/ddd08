import SwiftUI
import SwiftData

struct TodoListView: View {
    @StateObject var viewModel: TodoListViewModel
    @State private var isShowingAddSheet = false
    @State private var isShowingSettingsDialog = false
    @State private var isShowingSearch = false
    @State private var isShowingFilter = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    let grouped = Dictionary(grouping: viewModel.todos) { todo in
                        todo.projectID?.uuidString ?? "Без группы"
                    }

                    let sortedGroups = grouped.keys.sorted()

                    ForEach(sortedGroups, id: \.self) { group in
                        if let todos = grouped[group] {
                            Section(header: Text(group).font(.headline).padding(.top)) {
                                ForEach(todos, id: \.id) { todo in
                                    TodoRowView(todo: todo, viewModel: viewModel)
                                }
                            }
                        }
                    }

                    if grouped.isEmpty {
                        Text("Нет задач")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Задачи")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        isShowingSettingsDialog = true
                    } label: {
                        Image(systemName: "ellipsis")
                    }

                    Button {
                        isShowingSearch = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }

                    Button {
                        isShowingFilter = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }

                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Spacer()
                        Button(action: {
                            isShowingAddSheet = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.accentColor)
                        }
                        .padding(.trailing)
                    }
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                TodoDetailView(viewModel: TodoDetailViewModel())
                    .presentationDetents([.medium, .large])
            }
            .confirmationDialog("Дополнительно", isPresented: $isShowingSettingsDialog) {
                Button("Сортировать по дате") { /* TODO */ }
                Button("Показать выполненные") { /* TODO */ }
                Button("Удалить все задачи", role: .destructive) { /* TODO */ }
            }
            .sheet(isPresented: $isShowingSearch) {
                Text("Поиск задач")
                    .font(.title)
            }
            .sheet(isPresented: $isShowingFilter) {
                Text("Фильтрация по дате")
                    .font(.title)
            }
        }
    }
}
