import SwiftUI

// MARK: - MODELS

struct Entry: Identifiable {
    let id = UUID()
    let text: String
    let time = Date()
}

struct Memory: Identifiable {
    let id = UUID()
    var name: String
    var entries: [Entry]
}

// MARK: - MAIN VIEW

struct ContentView: View {
    
    @State private var memories: [Memory] = [
        Memory(name: "SE Class", entries: []),
        Memory(name: "Personal", entries: [])
    ]
    
    @State private var archivedMemories: [Memory] = []
    @State private var newMemoryName = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                
                // HEADER
                VStack(spacing: 10) {
                    Text("Heyaa 👋")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Welcome Buddy")
                        .font(.title2)
                    
                    Text("What's on your mind today?")
                        .foregroundColor(.gray)
                    
                    Text("Come type your emotions below ❤️")
                        .foregroundColor(.gray)
                }
                .padding()
                
                // ADD MEMORY
                HStack {
                    TextField("New memory...", text: $newMemoryName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Add") {
                        if !newMemoryName.isEmpty {
                            memories.append(Memory(name: newMemoryName, entries: []))
                            newMemoryName = ""
                        }
                    }
                }
                .padding(.horizontal)
                
                // MEMORY LIST
                List {
                    
                    Section(header: Text("Memories")) {
                        ForEach(memories) { memory in
                            NavigationLink(destination: MemoryDetailView(memory: binding(for: memory))) {
                                Text(memory.name)
                            }
                            .swipeActions(edge: .trailing) {
                                
                                // DELETE
                                Button(role: .destructive) {
                                    delete(memory)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                // ARCHIVE
                                Button {
                                    archive(memory)
                                } label: {
                                    Label("Archive", systemImage: "archivebox")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                    
                    // ARCHIVED SECTION
                    if !archivedMemories.isEmpty {
                        Section(header: Text("Archived")) {
                            ForEach(archivedMemories) { memory in
                                NavigationLink(destination: MemoryDetailView(memory: bindingArchived(for: memory))) {
                                    Text(memory.name)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Private Diary")
        }
    }
    
    // MARK: - HELPERS
    
    func binding(for memory: Memory) -> Binding<Memory> {
        guard let index = memories.firstIndex(where: { $0.id == memory.id }) else {
            fatalError("Memory not found")
        }
        return $memories[index]
    }
    
    func bindingArchived(for memory: Memory) -> Binding<Memory> {
        guard let index = archivedMemories.firstIndex(where: { $0.id == memory.id }) else {
            fatalError("Memory not found")
        }
        return $archivedMemories[index]
    }
    
    func delete(_ memory: Memory) {
        memories.removeAll { $0.id == memory.id }
    }
    
    func archive(_ memory: Memory) {
        memories.removeAll { $0.id == memory.id }
        archivedMemories.append(memory)
    }
}

// MARK: - MEMORY DETAIL

struct MemoryDetailView: View {
    
    @Binding var memory: Memory
    @State private var newText = ""
    
    var body: some View {
        VStack {
            
            // DATE
            Text(Date(), style: .date)
                .font(.headline)
                .padding(.top)
            
            // CHAT STYLE LIST
            List {
                ForEach(memory.entries) { entry in
                    HStack {
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text(entry.text)
                                .padding()
                                .background(Color.green.opacity(0.8))
                                .cornerRadius(12)
                            
                            Text(entry.time, style: .time)
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete { indexSet in
                    memory.entries.remove(atOffsets: indexSet)
                }
            }
            
            // INPUT BAR
            HStack {
                TextField("Write your memory...", text: $newText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button {
                    if !newText.isEmpty {
                        memory.entries.append(Entry(text: newText))
                        newText = ""
                    }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
            .padding()
        }
        .navigationTitle(memory.name)
    }
}
