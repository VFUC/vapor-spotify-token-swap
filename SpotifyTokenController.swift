import Foundation
import Vapor

struct SpotifyTokenController {
	func swap(req: Request) throws -> EventLoopFuture<SpotifyTokenSwap.Response> {
		guard let spotify = try? SpotifyEnvironment() else {
			return req.eventLoop.makeFailedFuture(Abort(.internalServerError))
		}
		let appRequest = try req.content.decode(SpotifyTokenSwap.Request.self)

		return req.client.post(spotify.tokenEndpoint) { spotifyRequest in
			spotifyRequest.headers.add(name: "Authorization", value: "Basic \(spotify.encodedBasicCredentials ?? "")")
			try spotifyRequest.content.encode([
				"grant_type": "authorization_code",
				"redirect_uri": spotify.clientCallbackUrl,
				"code": appRequest.code
			], as: .urlEncodedForm)
		}.flatMapThrowing { spotifyResponse in
			let tokenData = try spotifyResponse.content.decode(SpotifyTokenSwap.SpotifyResponse.self)
			guard let encrypted = self.encryptToken(tokenData.refresh_token, secret: spotify.encryptionSecret) else { throw Abort(.internalServerError) }
			return SpotifyTokenSwap.Response(refresh_token: encrypted, access_token: tokenData.access_token, expires_in: tokenData.expires_in)
		}
	}
	
	
	func refresh(req: Request) throws -> EventLoopFuture<SpotifyTokenRefresh.Response> {
		guard let spotify = try? SpotifyEnvironment() else {
			return req.eventLoop.makeFailedFuture(Abort(.internalServerError))
		}
		
		let appRequest = try req.content.decode(SpotifyTokenRefresh.Request.self)
		guard let decryptedToken = decryptToken(appRequest.refresh_token, secret: spotify.encryptionSecret) else { throw Abort(.internalServerError) }
		
		return req.client.post(spotify.tokenEndpoint) { spotifyRequest in
			spotifyRequest.headers.add(name: "Authorization", value: "Basic \(spotify.encodedBasicCredentials ?? "")")
			try spotifyRequest.content.encode([
				"grant_type": "refresh_token",
				"refresh_token": decryptedToken
			], as: .urlEncodedForm)
		}.flatMapThrowing { spotifyResponse in
			let tokenData = try spotifyResponse.content.decode(SpotifyTokenRefresh.SpotifyResponse.self)
			return SpotifyTokenRefresh.Response(access_token: tokenData.access_token, expires_in: tokenData.expires_in)
		}
	}
	
	func encryptToken(_ token: String, secret: String) -> String? {
		guard let secretData = secret.data(using: .utf8) else { return nil }
		let key = SymmetricKey(data: SHA256.hash(data: secretData))
		
		guard let tokenData = token.data(using: .utf8) else { return nil }
		guard let sealedData = try? ChaChaPoly.seal(tokenData, using: key).combined else { return nil }
		return sealedData.base64EncodedString()
	}
	
	func decryptToken(_ from: String, secret: String) -> String? {
		guard let secretData = secret.data(using: .utf8) else { return nil }
		let key = SymmetricKey(data: SHA256.hash(data: secretData))
		
		guard let decodedData = Data(base64Encoded: from) else { return nil }
		guard let sealedBox = try? ChaChaPoly.SealedBox(combined: decodedData) else { return nil }
		guard let decrypted = try? ChaChaPoly.open(sealedBox, using: key) else { return nil }
		return String(data: decrypted, encoding: .utf8)
	}
}
