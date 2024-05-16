//eslint ignore
import { run } from 'cmd-ts'
import { shuffle } from './index'

run(shuffle, process.argv.slice(2))
