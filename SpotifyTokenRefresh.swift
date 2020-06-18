import Foundation
import Vapor

struct SpotifyTokenRefresh {
	// We get this from the client
	struct Request: Codable {
		let refresh_token: String
	}
	
	// We send this back to the client
	struct Response: Content {
		let access_token: String
		let expires_in: Int
	}
	
	// We get this back from the Spotify API
	struct SpotifyResponse: Codable {
		let access_token: String
		let expires_in: Int
	}
}
