detected_OS := $(shell uname | tr '[:upper:]' '[:lower:]' 2> /dev/null || echo Unknown)
detected_OS := $(patsubst CYGWIN%,Cygwin,$(detected_OS))
detected_OS := $(patsubst MSYS%,MSYS,$(detected_OS))
detected_OS := $(patsubst MINGW%,MSYS,$(detected_OS))

APP = $(shell basename $(shell git remote get-url origin) | cut -d"." -f1)
REGESTRY := olhacheberakha
VERSION = $(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS = ${detected_OS}
TARGETARCH := amd64

format:
	gofmt -s -w ./

get:
	go get

lint:
	golint

test:
	go test -v

build: format get
	@printf "$GDetected OS/ARCH: $R${TARGETOS}/${TARGETARCH}$D\n"
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/helga-cheberakha/kbot/cmd.appVersion=${VERSION}

linux: format get
	@printf "$GTarget OS/ARCH: $Rlinux/${TARGETARCH}$D\n"
	CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/vit-um/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=linux -t ${REGESTRY}/${APP}:${VERSION}-linux-${TARGETARCH} .

windows: format get
	@printf "$GTarget OS/ARCH: $Rwindows/${TARGETARCH}$D\n"
	CGO_ENABLED=0 GOOS=windows GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/vit-um/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=windows -t ${REGESTRY}/${APP}:${VERSION}-windows-${TARGETARCH} .

darwin:format get
	@printf "$GTarget OS/ARCH: $Rdarwin/${TARGETARCH}$D\n"
	CGO_ENABLED=0 GOOS=darwin GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/vit-um/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=darwin -t ${REGESTRY}/${APP}:${VERSION}-darwin-${TARGETARCH} .

arm: format get
	@printf "$GTarget OS/ARCH: $R${TARGETOS}/arm$D\n"
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=arm go build -v -o kbot -ldflags "-X="github.com/vit-um/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=arm -t ${REGESTRY}/${APP}:${VERSION}-${TARGETOS}-arm .

image:
	docker build . -t ${REGESTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH} --build-arg TARGETOS=${TARGETOS} --build-arg TARGETARCH=${TARGETARCH}

push:
	docker push ${REGESTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}

clean:
	@rm -rf kbot; \
	IMG1=$$(docker images -q | head -n 1); \
	if [ -n "$${IMG1}" ]; then  docker rmi -f $${IMG1}; else printf "$RImage not found$D\n"; fi
