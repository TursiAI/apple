import Foundation

struct Integration: Identifiable, Codable {
    let id: String                 // "gmail", "web-search", etc.
    var displayName: String
    var icon: String               // SF Symbol name
    var isEnabled: Bool
    var permissionLevel: PermissionLevel
    var mcpEndpoint: MCPEndpoint
    var authState: AuthState

    init(
        id: String,
        displayName: String,
        icon: String,
        isEnabled: Bool = false,
        permissionLevel: PermissionLevel = .askEveryTime,
        mcpEndpoint: MCPEndpoint = .builtIn,
        authState: AuthState = .none
    ) {
        self.id = id
        self.displayName = displayName
        self.icon = icon
        self.isEnabled = isEnabled
        self.permissionLevel = permissionLevel
        self.mcpEndpoint = mcpEndpoint
        self.authState = authState
    }
}

enum PermissionLevel: String, Codable {
    case askEveryTime
    case allowAlways
}

enum MCPEndpoint: Codable {
    case builtIn
    case local(path: String)
    case remote(url: URL)
}

enum AuthState: String, Codable {
    case none          // no auth needed
    case required      // needs auth, not yet done
    case authenticated // auth complete
}
