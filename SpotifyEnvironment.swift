import Foundation
import Vapor

struct SpotifyEnvironment {
	public let clientId: String
	public let clientSecret: String
	public let encryptionSecret: String
	public let clientCallbackUrl: String
	public let accountsEndpoint: String // currently "https://accounts.spotify.com"
	
	init() throws {
		self.clientId = try Environment.getOrThrow(key: "SPOTIFY_CLIENT_ID")
		self.clientSecret = try Environment.getOrThrow(key: "SPOTIFY_CLIENT_SECRET")
		self.encryptionSecret = try Environment.getOrThrow(key: "SPOTIFY_ENCRYPTION_SECRET")
		self.clientCallbackUrl = try Environment.getOrThrow(key: "SPOTIFY_CLIENT_CALLBACK_URL")
		self.accountsEndpoint = try Environment.getOrThrow(key: "SPOTIFY_ACCOUNTS_ENDPOINT")
	}
	
	var encodedBasicCredentials: String? {
		return "\(clientId):\(clientSecret)".data(using: .utf8)?.base64EncodedString()
	}
	
	var tokenEndpoint: URI {
		return URI(string: accountsEndpoint + "/api/token")
	}
}

extension Environment {
	enum EnvironmentError: Error {
		case missingEnvironmentValue
	}
	
	static func getOrThrow(key: String) throws -> String {
		guard let val = get(key) else {
			throw EnvironmentError.missingEnvironmentValue
		}
		return val
	}
}
