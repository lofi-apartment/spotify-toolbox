export const toChunks = <T>(items: T[], chunkSize: number): T[][] => {
    const chunks: T[][] = []
    for (let i = 0; i < items.length; i += chunkSize) {
        chunks.push(items.slice(i, i + chunkSize))
    }
    return chunks
}

export const shuffleArray = <T>(array: T[]): T[] => {
    let currentIndex = array.length
    let randomIndex: number

    // While there remain elements to shuffle.
    while (currentIndex != 0) {

        // Pick a remaining element.
        randomIndex = Math.floor(Math.random() * currentIndex)
        currentIndex--;

        // And swap it with the current element.
        [array[currentIndex], array[randomIndex]] = [
            array[randomIndex], array[currentIndex]]
    }

    return array
}
