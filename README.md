
# Vapor-based Spotify Token Swap Service

This is a [Vapor](https://vapor.codes)-based implementation of a Spotify Token Swap Service.

This repository does not contain a self-running application, but provides files which can be plugged or adapted into a Vapor-based project.

The given code compiles and runs with Vapor version `4.10.0`.

I'm using these exact files in a current project and haven't encountered any issues so far, but plan to update this repo if I do.


### Overview of procedure

Basically: 

If you want to make API calls for a Spotify user from a client (e.g. an App), you need a token.

The client asks this backend service for a token, which will then contact the Spotify API and return a token, if all credentials match. This is the "token swap" .

The tokens expire, so there's another endpoint to "refresh" the Spotify token with a refresh token, which also gets returned during token swap.

In my implementation, the Spotify credentials are pulled from the environment, as can be seen in `SpotifyEnvironment.swift`

### References

This implementation is basically an adapted version of [this ruby-based example](https://github.com/spotify/ios-sdk/blob/master/DemoProjects/spotify_token_swap.rb).

Another ruby-based implementation can be found [here](https://github.com/bih/spotify-token-swap-service).

The Spotify documentation of the authorization flow can be found [here](https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow).

