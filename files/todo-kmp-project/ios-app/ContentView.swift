import SwiftUI
import Combine
import shared

struct ContentView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var showingAddTask = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.tasks.isEmpty {
                    ProgressView()
                } else if viewModel.tasks.isEmpty {
                    Text("No hay tareas. ¡Agrega una!")
                        .foregroundColor(.gray)
                } else {
                    List {
                        ForEach(viewModel.tasks, id: \.id) { task in
                            TaskRow(
                                task: task,
                                onToggle: { viewModel.toggleTask(taskId: task.id) },
                                onDelete: { viewModel.deleteTask(taskId: task.id) }
                            )
                        }
                    }
                }
            }
            .navigationTitle("Mis Tareas")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(viewModel: viewModel, isPresented: $showingAddTask)
            }
            .alert(item: $viewModel.errorMessage) { error in
                Alert(
                    title: Text("Error"),
                    message: Text(error.message),
                    dismissButton: .default(Text("OK")) {
                        viewModel.clearError()
                    }
                )
            }
        }
        .onAppear {
            viewModel.loadTasks()
        }
    }
}

struct TaskRow: View {
    let task: Task
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.completed ? .green : .gray)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.completed)
                    .foregroundColor(task.completed ? .gray : .primary)
                
                Text(task.description_)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
    }
}

struct AddTaskView: View {
    @ObservedObject var viewModel: TaskViewModel
    @Binding var isPresented: Bool
    
    @State private var title = ""
    @State private var description = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Detalles de la tarea")) {
                    TextField("Título", text: $title)
                    
                    TextEditor(text: $description)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                }
            }
            .navigationTitle("Nueva Tarea")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Crear") {
                        viewModel.addTask(title: title, description: description)
                        isPresented = false
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

// ViewModel específico de iOS que envuelve el repositorio compartido
class TaskViewModel: ObservableObject {
    private let repository = TaskRepository(api: TaskApi(baseUrl: "http://localhost:8080"))
    
    @Published var tasks: [shared.Task] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: ErrorMessage?
    
    init() {
        // Observar cambios del repositorio
        observeRepository()
    }
    
    private func observeRepository() {
        // En una implementación real, usarías Combine o similar
        // para observar los StateFlows del repositorio
        // Por ahora, esta es una implementación simplificada
    }
    
    func loadTasks() {
        isLoading = true
        _Concurrency.Task {
            do {
                try await repository.loadTasks()
                await MainActor.run {
                    self.tasks = repository.tasks.value as! [Task]
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = ErrorMessage(message: error.localizedDescription)
                    self.isLoading = false
                }
            }
        }
    }
    
    func addTask(title: String, description: String) {
        _Concurrency.Task {
            do {
                let success = try await repository.addTask(title: title, description: description)
                if success {
                    await MainActor.run {
                        self.tasks = repository.tasks.value as! [Task]
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = ErrorMessage(message: error.localizedDescription)
                }
            }
        }
    }
    
    func toggleTask(taskId: Int64) {
        _Concurrency.Task {
            do {
                try await repository.toggleTaskCompletion(taskId: taskId)
                await MainActor.run {
                    self.tasks = repository.tasks.value as! [Task]
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = ErrorMessage(message: error.localizedDescription)
                }
            }
        }
    }
    
    func deleteTask(taskId: Int64) {
        _Concurrency.Task {
            do {
                try await repository.deleteTask(taskId: taskId)
                await MainActor.run {
                    self.tasks = repository.tasks.value as! [Task]
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = ErrorMessage(message: error.localizedDescription)
                }
            }
        }
    }
    
    func clearError() {
        errorMessage = nil
        repository.clearError()
    }
}

struct ErrorMessage: Identifiable {
    let id = UUID()
    let message: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
