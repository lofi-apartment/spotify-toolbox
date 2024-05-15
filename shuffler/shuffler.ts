import { SpotifyApi, Track } from '@spotify/web-api-ts-sdk'

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
    playlistId: string

    constructor(sdk: SpotifyApi, playlistUrl: string) {
        this.sdk = sdk
        this.playlistId = parsePlaylistId(playlistUrl)
    }

    async listTracks(): Promise<Track[][]> {
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

        const chunks: Track[][] = []
        const chunkSize = 100
        for (let i = 0; i < tracks.length; i += chunkSize) {
            chunks.push(tracks.slice(i, i + chunkSize))
        }

        return chunks
    }

    async shuffle() {
        const tracks = await this.listTracks()
        console.log(tracks)
    }

}

export default Shuffler
