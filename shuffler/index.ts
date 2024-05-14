import {
    command,
    positional,
    string,
    run,
} from 'cmd-ts'

const shuffle = command({
    name: 'shuffle',
    args: {
        collectionUrl: positional({ type: string, displayName: 'collection url', }),
    },
    handler: ({ collectionUrl }) => {
        console.log('Collection URL:', collectionUrl)
    },
})

run(shuffle, process.argv.slice(2))