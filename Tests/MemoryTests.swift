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

@Test func memoryPinSetsImportance() {
    var memory = Memory(
        description: "Always reply in Spanish",
        content: "User wants all responses in Spanish",
        type: .instruction,
        isPinned: true,
        importance: 1.0
    )
    #expect(memory.isPinned == true)
    #expect(memory.importance == 1.0)

    memory.isPinned = false
    memory.importance = 0.5
    #expect(memory.importance == 0.5)
}
