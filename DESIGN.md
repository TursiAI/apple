# Tursi v2 — Design Document

## Vision

A privacy-first AI chat app for Apple platforms (iOS, iPadOS, macOS). Local LLM runs on-device, memories are E2E encrypted, and the user controls what the AI can access via MCP integrations. The cloud is a dumb encrypted sync layer — it never sees plaintext.

## Core Value Proposition

- **True Privacy**: Local LLM + E2EE memories. Server never sees your data.
- **Persistent Memory**: AI remembers across conversations — preferences, context, history.
- **Extensible**: MCP integrations let the AI interact with email, web, calendar, etc.
- **Cross-Device**: Encrypted sync across iPhone, iPad, Mac.
- **Consumer-Friendly**: No setup, no jargon. It just works.

## Architecture Overview

```
┌─────────────────────────────────────────────────┐
│                   Device                         │
│                                                  │
│  ┌──────────┐   ┌───────────┐   ┌────────────┐  │
│  │  Chat UI  │──│ Local LLM │──│ MCP Client  │  │
│  └──────────┘   └───────────┘   └─────┬──────┘  │
│       │              │                 │         │
│       │         ┌────┴─────┐     ┌─────┴──────┐  │
│       │         │ Memory   │     │ MCP Servers │  │
│       │         │ Extractor│     │ Gmail,Web,  │  │
│       │         └────┬─────┘     │ Calendar,...│  │
│       │              │           └────────────┘  │
│  ┌────┴──────────────┴──────┐                    │
│  │     Local Database        │                    │
│  │  (SQLite, plaintext)      │                    │
│  └────────────┬─────────────┘                    │
│               │                                  │
│  ┌────────────┴─────────────┐                    │
│  │   Encryption Layer        │                    │
│  │   (CryptoKit AES-256-GCM)│                    │
│  └────────────┬─────────────┘                    │
└───────────────┼──────────────────────────────────┘
                │ encrypted blobs only
                ▼
┌──────────────────────────────┐
│        Tursi Cloud            │
│                               │
│  Auth (Apple Sign-In / email) │
│  Encrypted Blob Storage       │
│  Sync Protocol                │
│  Push Notifications           │
│                               │
│  No plaintext ever            │
└──────────────────────────────┘
```

## Screens & Navigation

### iPhone (Tab Bar)
- Chat — conversation list + chat view
- Memory — browse, search, edit memories
- Settings — model, integrations, privacy, account

### iPad / Mac (Sidebar)
Same screens, sidebar navigation instead of tab bar.

### Screen Breakdown

**1. Chat (Main Screen)**
- Conversation list (left/drawer on iPad+)
- Chat view with message bubbles
- Streaming responses with typing indicator
- New conversation button
- Model indicator (Standard / Enhanced) — subtle
- Tool use indicators ("Searching the web...", "Reading email...")

**2. Memory**
- List of all memories, grouped by category
- Search bar (local search over descriptions + tags)
- Tap to view full decrypted content
- Swipe to delete, tap to edit
- Each memory shows: description, tags, date, source conversation

**3. Settings**

- **AI Model**: Standard (built-in) / Enhanced (download). Download progress + storage used.
- **Integrations**: Toggle grid of MCP integrations. Each shows icon, name, on/off, auth status. "Add Custom Server" for power users. Per-integration permission level (ask every time / allow always).
- **Memory Settings**: Auto-extract on/off, categories, extraction timing.
- **Account**: Sign-in, sync status, export data, delete account.
- **Privacy**: E2EE status, recovery key backup, data transparency.

## Data Models

### Conversation
```swift
struct Conversation {
    let id: UUID
    var title: String
    var messages: [Message]
    let createdAt: Date
    var updatedAt: Date
    var isArchived: Bool
}
```

### Message
```swift
struct Message {
    let id: UUID
    let conversationId: UUID
    let role: MessageRole          // .user, .assistant, .system, .tool
    var content: String
    var toolCalls: [ToolCall]?
    var toolResults: [ToolResult]?
    let timestamp: Date
}
```

### Memory
```swift
struct Memory {
    let id: UUID
    var description: String        // plaintext, searchable summary
    var content: String            // full detail (E2EE in cloud)
    var tags: [MemoryTag]
    var type: MemoryType           // .preference, .fact, .instruction, .context
    var source: MemorySource
    var isPinned: Bool
    var importance: Float
    let createdAt: Date
    var updatedAt: Date
    var lastAccessedAt: Date
}
```

### Integration (MCP)
```swift
struct Integration {
    let id: String
    var displayName: String
    var icon: String               // SF Symbol name
    var isEnabled: Bool
    var permissionLevel: PermissionLevel  // .askEveryTime, .allowAlways
    var mcpEndpoint: MCPEndpoint   // .builtIn, .local(path), .remote(url)
    var authState: AuthState
}
```

### Sync Envelope (what the cloud sees)
```swift
struct SyncEnvelope {
    let id: UUID
    let userId: String
    let entityType: String
    let encryptedPayload: Data     // AES-256-GCM ciphertext
    let iv: Data
    let version: Int64
    let updatedAt: Date
    let isDeleted: Bool
}
```

## Core Systems

### 1. LLM Engine

Two implementations behind a shared protocol:
- **AppleFoundationModelEngine** — default, uses Apple's on-device models, zero setup
- **MLXModelEngine** — enhanced, user downloads a model (~1.5-2GB)

Memory injection: before each LLM call, search local memories by relevance, inject top-N into system prompt. Pinned memories (instructions) always included.

### 2. Memory Extraction

Runs after conversation ends or idle >5 minutes:
1. Feed conversation to LLM with extraction prompt
2. LLM returns structured list of new memories
3. Dedup against existing memories
4. Save new / update existing

### 3. Encryption

- **Local**: SQLite with SQLCipher (encrypted at rest)
- **Cloud E2EE**: User key derived via Argon2id from password, AES-256-GCM per entity
- **Recovery key**: Generated at signup, user must back it up

### 4. Sync Protocol

- Offline-first, version-counter per entity
- Push/pull encrypted envelopes
- Last-write-wins for conflicts
- Tombstones for deletions
- Background sync via iOS Background Tasks

### 5. MCP Client

App acts as MCP host. On tool call:
1. Check if integration is enabled
2. If permission = askEveryTime, show confirmation dialog
3. Route to MCP server (built-in, local, or remote)
4. Feed result back to LLM

Built-in: web search, device files.
OAuth: Gmail, Calendar, GitHub, etc.
Custom: any MCP server URL.

## Project Structure

```
Tursi/
├── TursiApp.swift
├── Package.swift
│
├── Core/
│   ├── LLM/
│   │   ├── LLMEngine.swift           # Protocol
│   │   ├── AppleEngine.swift
│   │   └── MLXEngine.swift
│   ├── Memory/
│   │   ├── MemoryStore.swift
│   │   ├── MemoryExtractor.swift
│   │   └── MemorySearch.swift
│   ├── MCP/
│   │   ├── MCPClient.swift
│   │   ├── MCPRouter.swift
│   │   └── Integrations/
│   ├── Sync/
│   │   ├── SyncEngine.swift
│   │   ├── SyncEnvelope.swift
│   │   └── ConflictResolver.swift
│   ├── Crypto/
│   │   ├── KeyManager.swift
│   │   └── E2EE.swift
│   └── Data/
│       ├── Models/
│       ├── Database.swift
│       └── Migrations/
│
├── Features/
│   ├── Chat/
│   │   ├── ChatListView.swift
│   │   ├── ChatView.swift
│   │   ├── ChatViewModel.swift
│   │   └── MessageBubble.swift
│   ├── Memory/
│   │   ├── MemoryListView.swift
│   │   ├── MemoryDetailView.swift
│   │   └── MemoryViewModel.swift
│   └── Settings/
│       ├── SettingsView.swift
│       ├── ModelSettingsView.swift
│       ├── IntegrationsView.swift
│       ├── PrivacyView.swift
│       └── AccountView.swift
│
├── Shared/
│   ├── Components/
│   ├── Extensions/
│   └── Theme.swift
│
└── Cloud/
    └── server/                       # Stripped-down backend: auth + sync only
```

## Cloud API (Minimal)

```
POST   /auth/apple           # Apple Sign-In token -> JWT
POST   /auth/email            # Email/password fallback
POST   /sync/push             # Upload encrypted envelopes
POST   /sync/pull             # Fetch envelopes since version X
DELETE /sync/entity/:id       # Tombstone an entity
GET    /account               # Account info
DELETE /account               # Delete everything
```

No memory logic, no embeddings, no vector DB. Just auth + encrypted blob CRUD.

## Build Phases

### Phase 1 — Chat MVP
SwiftUI app shell, Apple Foundation Models integration, basic chat UI with streaming, conversation persistence (local SQLite), dark theme.

### Phase 2 — Memory
Memory extraction pipeline, memory list/detail UI, memory injection into chat context, local search.

### Phase 3 — E2EE + Sync
CryptoKit encryption layer, cloud backend (auth + sync), cross-device encrypted sync, recovery key flow.

### Phase 4 — MCP Integrations
MCP client implementation, web search (built-in), integration toggle UI, OAuth flows for external services, per-action permission prompts.

### Phase 5 — Enhanced Model
MLX Swift engine, model download + management UI, seamless switching.

### Phase 6 — Polish
iPad + Mac adaptive layouts, Siri/Shortcuts integration, share extension, widget.
