'use strict'

const Elm = require('./elm.js')
const rawSettings = localStorage.getItem('flusher-settings')
const settings = rawSettings ? JSON.parse(rawSettings) : null
const flusher = Elm.Flusher.fullscreen(settings)

flusher.ports.setStorage.subscribe(function (settings) {
    localStorage.setItem('flusher-settings', JSON.stringify(settings));
})
