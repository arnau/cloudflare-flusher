flush-cache-gp:
	@curl -XDELETE "https://api.cloudflare.com/client/v4/zones/9919c7373042e338d98389deb0111ba8/purge_cache" \
        -H "Content-Type:application/json" \
        -H "X-Auth-Email: arnau@greypistachio.com" \
        -H "X-Auth-Key: $(CLOUDFLARE_TOKEN)" \
        --data '{"files": ["https://www.greypistachio.com/blog"]}'


build:
	elm-make Todo.elm --output elm.js
	electron-packager ./ flusher --platform=darwin --arch=x64 --version=1.3.4
