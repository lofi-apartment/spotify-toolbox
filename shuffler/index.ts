import { SpotifyApi } from '@spotify/web-api-ts-sdk'
import { command, string, option } from 'cmd-ts'
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
        const shuffler = new Shuffler(sdk, playlistUrl)
        await shuffler.shuffle()
    },
})


