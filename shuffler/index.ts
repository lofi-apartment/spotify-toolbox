import {
    command,
    positional,
    string,
    boolean,
    flag,
    run,
} from 'cmd-ts'
  
const yesFlag = flag({
    type: boolean,
    long: 'yes',
    short: 'y',
})

const shuffle = command({
    name: 'shuffle',
    args: {
        collectionUrl: positional({ type: string, displayName: 'collection url', }),
    },
    handler: ({ collectionUrl }) => {
        console.log(collectionUrl)
    },
})