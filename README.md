# Red Hat Openshift Service Mesh WASM Plugin

This repository tries to collect the information required to implement a new WASM Plugin in the Red Hat Service Mesh.

The idea is to implement a filter that perform an HTTP requests every HTTP request that receive a specific microservice.

```$bash
## Workflow

User ==(http request)==> back-golang  ==(http response)==> User
                            ||
                        (WASM Plugin) ==(http request)==> back-python
```

Note: the same logic can be performed for http *requests* as well with the corresponding functions.

## Prerequisites

It is required to install and configure some components in order to be able to work with WASM plugins in Go.

Please follow the next steps in order to ensure the laptop has the required tools.

- Install podman [Official Doc](https://podman.io/getting-started/installation)

- Download the respective Tinygo container image

```$bash
docker pull docker.io/tinygo/tinygo:0.25.0
```

- Install the respective golang version [Official Doc](https://go.dev/doc/install)

```$bash
sudo tar -C /usr/local/bin -xzf ~/Downloads/go1.19.1.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/bin/go/bin
```

## Setup

Once the prerequisites are met, it is time to define the filter and build a container image that includes the WASM plugin file. 

In terms of steps, the following procedure should be executed:

- Add the filter logic in Golang (file main.go)

- Build the respective WASM file and container image that includes the WASM plugin

```$bash
make container.push
```

- Deploy the filter in Openshift

```$bash
oc apply -f example/wasmplugin.yaml
```

In order to verify if the WASM plugin has been loaded properly, it is possible to review the istiod logs:

```$bash
# Istiod Logs
2022-09-21T10:02:47.574533Z info ads Push debounce stable[23] 1 for config WasmPlugin/istio-system/wasm-http-request: 100.195111ms since last change, 100.194678ms since last push, full=true
```

## Test

It is required to execute HTTP request to back-golang and review back-python is receiving HTTP requests as well from back-golang.

```$bash

curl https://back-golang-jump-app-dev.apps.acidonpe01.sandbox140.opentlc.com/jump -k

# Log Golang

2022/09/21 10:44:28 Received GET /jump
2022/09/21 10:44:28 Headers -> map[Accept:[*/*] Forwarded:[for=83.32.80.178;host=back-golang-jump-app-dev.apps.acidonpe01.sandbox140.opentlc.com;proto=https] User-Agent:[curl/7.79.1] X-B3-Parentspanid:[33d97a9620a7ffb2] X-B3-Sampled:[1] X-B3-Spanid:[ffb8837c93541608] X-B3-Traceid:[78aa770d2619386c33d97a9620a7ffb2] X-Envoy-Attempt-Count:[1] X-Envoy-External-Address:[10.131.0.2] X-Forwarded-Client-Cert:[By=spiffe://cluster.local/ns/jump-app-dev/sa/default;Hash=a51675eebb54ad4177910f8d98ccfecb723a7958cd6fe61f17828e5547384885;Subject="";URI=spiffe://cluster.local/ns/istio-system/sa/istio-ingressgateway-service-account] X-Forwarded-For:[83.32.80.178,10.131.0.2] X-Forwarded-Host:[back-golang-jump-app-dev.apps.acidonpe01.sandbox140.opentlc.com] X-Forwarded-Port:[443] X-Forwarded-Proto:[http] X-Request-Id:[f7a5c698-96d9-9f00-ae30-8fcc618de954]]

# Log Python

127.0.0.6 - - [21/Sep/2022 10:44:28] "GET /jump HTTP/1.1" 200 -
166
JumpResponse[code: 200 ,message: /jump - Greetings from Python!]
```

## Author 

Asier Cidon @Red Hat