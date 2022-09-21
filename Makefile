VERSION = 0.1
SERVER = quay.io
HUB = quay.io/acidonpe
IMG = wasm-http-request
DIR = /home/acidonpe/friki/laptop-configuration/git_repositories/wasm-http-request

.PHONY: clean
clean:
	rm -f plugin.wasm
	rm -rf build

.PHONY: container
container: clean
    
	podman run --rm -v ${DIR}:/src:z -v /home/acidonpe/go:/go -e "GOPATH=/go" -w /src tinygo/tinygo:0.25.0 tinygo build -o /src/plugin.wasm -scheduler=none -target=wasi /src/main.go
	mkdir build
	cp container/manifest.yaml build/
	cp plugin.wasm build/
	cd build && podman build -t ${HUB}/${IMG}:${VERSION} . -f ../container/Dockerfile

container.push: container

	podman login ${SERVER}
	podman push ${HUB}/${IMG}:${VERSION}
	podman tag ${HUB}/${IMG}:${VERSION} ${HUB}/${IMG}:latest
	podman push ${HUB}/${IMG}:${VERSION}
	podman push ${HUB}/${IMG}:latest

# .PHONY: deploy
# deploy:

#     oc apply -f example/wasmplugin.yaml