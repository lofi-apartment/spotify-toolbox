import { SpotifyApi, Track } from '@spotify/web-api-ts-sdk'
import { toChunks, shuffleArray } from './utils'

const parsePlaylistId = (playlistURL: string): string => {
    const idStart = playlistURL.lastIndexOf('/')+1
    let idEnd = playlistURL.indexOf('?')
    if (idEnd < 0) {
        idEnd = playlistURL.length
    }

    return playlistURL.substring(idStart, idEnd)
}

const parseListNextOffset = (next: string): number | undefined => {
    const matchOffset = next?.match(/offset=([0-9]+)/)
    return matchOffset ? Number(matchOffset[1]) : undefined
}

export class Shuffler {

    sdk: SpotifyApi

    userId: string

    playlistId: string
    backupPlaylistId: string | undefined

    constructor(sdk: SpotifyApi, userId: string, playlistUrl: string) {
        this.sdk = sdk
        this.userId = userId
        this.playlistId = parsePlaylistId(playlistUrl)
        this.backupPlaylistId = undefined
    }

    // listTracks returns the tracks in a playlist
    async listTracks(): Promise<Track[]> {
        const tracks: Track[] = []
        let nextOffset: number | undefined

        try {
            do {
                const response = await this.sdk.playlists.getPlaylistItems(
                    this.playlistId,
                    undefined,
                    undefined,
                    50,
                    nextOffset,
                    undefined
                )

                for (const item of response.items) {
                    tracks.push(item.track)
                }

                nextOffset = parseListNextOffset(response.next ?? '')
            } while (nextOffset != undefined)
        } catch (e) {
            console.error('Error listing tracks:', e)
            process.exit(1)
        }

        return tracks
    }

    // playlistName returns the name of the playlist
    async playlistName(): Promise<string> {
        try {
            const response = await this.sdk.playlists.getPlaylist(this.playlistId)
            return response.name
        } catch (e) {
            console.error('Error listing tracks:', e)
            process.exit(1)
        }
    }

    // createBackup creates a backup of the playlist
    async createBackup(name: string, tracks: Track[]): Promise<void> {
        const createResponse = await this.sdk.playlists.createPlaylist(this.userId, {
            name: `${name} (backup)`,
            public: false,
        })

        this.backupPlaylistId = createResponse.id

        const trackUris = tracks.map(track => track.uri)
        const chunks = toChunks(trackUris, 100)
        for (const chunk of chunks) {
            await this.sdk.playlists.addItemsToPlaylist(this.backupPlaylistId, chunk)
        }
    }

    // emptyPlaylist removes all tracks from the playlist
    async emptyPlaylist(tracks: Track[]) {
        const chunks = toChunks(tracks, 100)
        for (const chunk of chunks) {
            await this.sdk.playlists.removeItemsFromPlaylist(this.playlistId, {
                tracks: chunk,
            })
        }
    }

    // repopuatePlaylist adds all tracks to the playlist in a random order
    async repopuatePlaylist(tracks: Track[]) {
        const uris = shuffleArray(tracks.map(track => track.uri))
        const chunks = toChunks(uris, 100)
        for (const chunk of chunks) {
            await this.sdk.playlists.addItemsToPlaylist(this.playlistId, chunk)
        }
    }

    async shuffle() {
        const name = await this.playlistName()
        const tracks = await this.listTracks()

        await this.createBackup(name, tracks)

        await this.emptyPlaylist(tracks)

        await this.repopuatePlaylist(tracks)
    }

}

export default Shuffler
