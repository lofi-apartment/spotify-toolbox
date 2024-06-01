import axios from 'axios'
import express, { Express, Request, Response } from 'express'
import { v4 as uuidv4 } from 'uuid'
import querystring from 'querystring'

export class AuthHelper {

    port: number
    server: Express

    clientId: string
    clientSecret: string
    scopes: string
    redirectUri: string

    accessToken?: string
    refreshToken?: string

    constructor(
        port: number,
        clientId: string,
        clientSecret: string,
        scopes: string[],
        redirectUri: string,
    ) {
        this.port = port
        this.server = express()

        this.clientId = clientId
        this.clientSecret = clientSecret
        this.scopes = scopes.join(' ')
        this.redirectUri = redirectUri

        this.server = express()
        this.setupRoutes()
    }

    setupRoutes() {
        let state = uuidv4()

        this.server.get('/login', async (req: Request, res: Response) => {
            state = uuidv4()
            return res.redirect('https://accounts.spotify.com/authorize?' +
                querystring.stringify({
                    show_dialog: true,
                    response_type: 'code',
                    client_id: this.clientId,
                    scope: this.scopes,
                    redirect_uri: this.redirectUri,
                    state: state,
                })
            )
        })

        this.server.get('/callback', async (req: Request, res: Response) => {
            if (req.query?.state != state) {
                res.status(400).send('Bad Request')
                return
            }

            try {
                const response = await axios.post(
                    'https://accounts.spotify.com/api/token',
                    {
                        code: req.query?.code,
                        redirect_uri: this.redirectUri,
                        grant_type: 'authorization_code',
                    },
                    {
                        headers: {
                            'content-type': 'application/x-www-form-urlencoded',
                            'Authorization': 'Basic ' + (Buffer.from(`${this.clientId}:${this.clientSecret}`).toString('base64')),
                        },
                    }
                )

                if (response.status == 200) {
                    this.accessToken = response.data['access_token']
                    this.refreshToken = response.data['refresh_token']
                    res.send('Accepted')
                    return
                }

                res.status(response.status).send(response.data)
            } catch (e) {
                res.status(500).send(e)
                return
            }
        })
    }

    async waitForToken(): Promise<string> {
        const http = this.server.listen(this.port)

        console.log(`http://localhost:${this.port}/login`)

        const totalWait = 5 * 60 * 1000
        const endTime = new Date((new Date()).getTime() + totalWait)

        while ((new Date()) < endTime) {
            if (this.accessToken) {
                return this.accessToken
            }

            await new Promise(resolve => setTimeout(resolve, 100))
        }

        http.close()
        console.error('No token after 5 minutes')
        process.exit(1)
    }

}
