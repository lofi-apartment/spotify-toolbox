import { command, string, option } from 'cmd-ts'

export const shuffle = command({
    name: 'shuffle',
    args: {
        clientId :option({
            type: string,
            long: 'client-id',
            short: 'i',
        }),
        clientSecret: option({
            type: string,
            long: 'client-secret',
            short: 's',
        }),
        playlistUrl: option({
            type: string,
            long: 'playlist-url',
            short: 'u',
        }),
    },
    handler: ({ clientId, clientSecret, playlistUrl }) => {
        console.log({
            clientId,
            clientSecret,
            playlistUrl,
        })
    },
})


