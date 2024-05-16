import { SpotifyApi } from '@spotify/web-api-ts-sdk'
import { command, string, option, optional } from 'cmd-ts'
import Shuffler from './shuffler'

const SDK_SCOPES = [
    'playlist-read-private',
    'playlist-modify-private',
    'playlist-modify-public',
]

export const shuffle = command({
    name: 'shuffle',
    args: {
        clientId :option({
            type: optional(string),
            long: 'client-id',
        }),
        clientSecret: option({
            type: optional(string),
            long: 'client-secret',
        }),
        playlistUrl: option({
            type: optional(string),
            long: 'playlist-url',
            short: 'url',
        }),
        userId: option({
            type: optional(string),
            long: 'user-id',
        }),
    },
    handler: async ({ clientId, clientSecret, playlistUrl, userId }) => {
        const id = clientId || process.env.CLIENT_ID || ''
        const secret = clientSecret || process.env.CLIENT_SECRET || ''
        const url = playlistUrl || process.env.PLAYLIST_ID || ''
        const user = userId || process.env.USER_ID || ''

        const sdk = SpotifyApi.withClientCredentials(id, secret, SDK_SCOPES)
        const shuffler = new Shuffler(sdk, user, url)
        await shuffler.shuffle()
    },
})


