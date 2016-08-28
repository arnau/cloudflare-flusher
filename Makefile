compile:
	elm-make Flusher.elm --output elm.js

start:
	electron .

build:
	electron-packager ./ flusher --platform=darwin --arch=x64 --version=1.3.4

clean:
	rm -rf flusher-darwin-x64
