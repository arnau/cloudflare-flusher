'use strict'
const electron = require('electron')

const app = electron.app
const BrowserWindow = electron.BrowserWindow

// saves a global reference to mainWindow so it doesn't get garbage collected
let mainWindow


app.on('ready', createWindow)

function createWindow() {
  mainWindow = new BrowserWindow({
    // width: 512,
    // height: 300
    width: 1024,
    height: 768
  })

  mainWindow.loadURL(`file://${__dirname}/index.html`)

  mainWindow.webContents.openDevTools()

  mainWindow.on('closed', () => {
    mainWindow = null
  })
}

// Mac Specific things
app.on('window-all-closed', () => {
  if (process.platform != 'darwin') { app.quit() }
})

app.on('activate', () => {
  if (mainWindow === null) { createWindow() }
})
