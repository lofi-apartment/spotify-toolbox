import { AuthHelper } from './authHelper'

const main = async () => {
    const helper = new AuthHelper(
        40001,
        process.env.CLIENT_ID || '',
        process.env.CLIENT_SECRET || '',
        ['playlist-modify-public', 'playlist-modify-private'],
        'http://localhost:40001/callback',
    )

    const token = await helper.waitForToken()
    console.log(JSON.stringify({
        access_token: token,
        refresh_token: helper.refreshToken || '',
    }, null, '    '))
}

main()
