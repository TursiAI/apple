import Testing
@testable import TursiCore

@Test func memoryCreation() {
    let memory = Memory(
        description: "Likes oat milk",
        content: "User prefers oat milk in their coffee",
        tags: [.preferences],
        type: .preference
    )
    #expect(memory.description == "Likes oat milk")
    #expect(memory.type == .preference)
    #expect(memory.isPinned == false)
    #expect(memory.importance == 0.5)
}

@Test func memoryStoreRoundTrip() throws {
    let db = try Database(inMemory: true)
    let store = MemoryStore(db: db)

    let memory = Memory(
        description: "Works at Acme",
        content: "User works at Acme Corp as a software engineer",
        tags: [.work],
        type: .fact
    )

    try store.save(memory)
    let fetched = try store.fetchAll()
    #expect(fetched.count == 1)
    #expect(fetched[0].description == "Works at Acme")
    #expect(fetched[0].tags == [.work])
}

@Test func memorySearch() throws {
    let db = try Database(inMemory: true)
    let store = MemoryStore(db: db)

    try store.save(Memory(description: "Likes oat milk", content: "Prefers oat milk", tags: [.preferences], type: .preference))
    try store.save(Memory(description: "Works at Acme", content: "Software engineer at Acme", tags: [.work], type: .fact))
    try store.save(Memory(description: "Has a dog", content: "Dog named Rex", tags: [.personal], type: .fact))

    let results = try store.search(query: "oat")
    #expect(results.count == 1)
    #expect(results[0].description == "Likes oat milk")
}

@Test func memoryDelete() throws {
    let db = try Database(inMemory: true)
    let store = MemoryStore(db: db)

    let memory = Memory(description: "Test", content: "Test content", type: .fact)
    try store.save(memory)
    #expect(try store.fetchAll().count == 1)

    try store.delete(memory.id)
    #expect(try store.fetchAll().count == 0)
}

@Test func memoryTogglePin() throws {
    let db = try Database(inMemory: true)
    let store = MemoryStore(db: db)

    let memory = Memory(description: "Pin me", content: "Content", type: .fact)
    try store.save(memory)

    try store.togglePin(memory.id)
    let pinned = try store.get(memory.id)
    #expect(pinned?.isPinned == true)
    #expect(pinned?.importance == 1.0)

    try store.togglePin(memory.id)
    let unpinned = try store.get(memory.id)
    #expect(unpinned?.isPinned == false)
    #expect(unpinned?.importance == 0.5)
}

@Test func conversationStoreRoundTrip() throws {
    let db = try Database(inMemory: true)
    let store = ConversationStore(db: db)

    let conv = Conversation(title: "Test Chat")
    try store.save(conv)

    let msg1 = Message(conversationId: conv.id, role: .user, content: "Hello")
    let msg2 = Message(conversationId: conv.id, role: .assistant, content: "Hi there!")
    try store.saveMessage(msg1)
    try store.saveMessage(msg2)

    let conversations = try store.fetchAll()
    #expect(conversations.count == 1)
    #expect(conversations[0].title == "Test Chat")

    let messages = try store.fetchMessages(for: conv.id)
    #expect(messages.count == 2)
    #expect(messages[0].role == .user)
    #expect(messages[1].content == "Hi there!")
}

@Test func conversationDeleteCascadesMessages() throws {
    let db = try Database(inMemory: true)
    let store = ConversationStore(db: db)

    let conv = Conversation()
    try store.save(conv)
    try store.saveMessage(Message(conversationId: conv.id, role: .user, content: "Hello"))

    try store.delete(conv.id)
    let messages = try store.fetchMessages(for: conv.id)
    #expect(messages.isEmpty)
}
