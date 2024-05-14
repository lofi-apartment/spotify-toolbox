import { SpotifyApi } from '@spotify/web-api-ts-sdk'
import { command, string, option } from 'cmd-ts'

const SDK_SCOPES = [
    'playlist-read-private',
    'playlist-modify-private',
    'playlist-modify-public',
]

const parsePlaylistId = (playlistURL: string): string => {
    const idStart = playlistURL.lastIndexOf('/')+1
    let idEnd = playlistURL.indexOf('?')
    if (idEnd < 0) {
        idEnd = playlistURL.length
    }

    return playlistURL.substring(idStart, idEnd)
}

export const shuffle = command({
    name: 'shuffle',
    args: {
        clientId :option({
            type: string,
            long: 'client-id',
        }),
        clientSecret: option({
            type: string,
            long: 'client-secret',
        }),
        playlistUrl: option({
            type: string,
            long: 'playlist-url',
            short: 'url',
        }),
    },
    handler: async ({ clientId, clientSecret, playlistUrl }) => {
        const sdk = SpotifyApi.withClientCredentials(clientId, clientSecret, SDK_SCOPES)
        const playlistId = parsePlaylistId(playlistUrl)

        try {
            const tracks = await sdk.playlists.getPlaylistItems(playlistId)
            console.log(JSON.stringify(tracks, null, 4))
        } catch (e) {
            console.error(e)
        }
    },
})


