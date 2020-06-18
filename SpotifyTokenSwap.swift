import Foundation
import Vapor

struct SpotifyTokenSwap {
	// We get this from the client
	struct Request: Codable {
		let code: String
	}
	
	// We send this back to the client
	struct Response: Content {
		let refresh_token: String
		let access_token: String
		let expires_in: Int
	}
	
	// We get this back from the Spotify API
	struct SpotifyResponse: Codable {
		let refresh_token: String
		let access_token: String
		let expires_in: Int
	}
}
