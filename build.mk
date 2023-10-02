GITTAG := $(shell git describe --exact-match --tags HEAD 2>/dev/null || :)
GITBRANCH := $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || :)
LONGVERSION := $(shell git describe --tags --long --abbrev=8 --always HEAD)$(shell echo -$(GITBRANCH) | tr / - | grep -v '\-master' || :)
GITCOMMIT := $(shell git log -1 --date=iso --pretty=format:%H)

# Used by go generate to inject version before build
export COMMIT_VERSION ?= $(if $(GITTAG),$(GITTAG),$(LONGVERSION))
export COMMIT_SHA ?= $(GITCOMMIT)

BUILD_TAGS ?=

DOCKER_BUILDKIT=1
BUILDKIT_PROGRESS=plain
DOCKER_CLI_EXPERIMENTAL=true
DOCKER_PLATFORM ?= linux/amd64

rp=)
GOOS ?= $(shell case "`uname`" in Darwin*$(rp) echo darwin;; Linux*$(rp) echo linux;; esac)
GOARCH ?= $(shell case "`uname -m`" in x86_64*$(rp) echo amd64;; i?86*$(rp) echo x86;; arm64|aarch64$(rp) echo arm64;; esac)

# build takes three parameters: the source directory, the output directory, and the binary name
define build
	cd $1 && \
	GOOS=$(GOOS) GOARCH=$(GOARCH) \
	GOPROXY=$(GOPROXY) \
	go build \
		-pgo=auto \
		-tags='$(BUILD_TAGS)' \
		-gcflags='-e' \
		-ldflags='-s -w' \
	-o $2/$3
endef

define build-image
	mkdir -p $1/out/
	rm -rf $1/out/image.tar.gz
	docker build \
		-f $1/Dockerfile \
		--platform $(DOCKER_PLATFORM) \
		--build-arg GOPROXY \
		--build-arg CONFIG=$2 \
		--build-arg COMMIT_SHA=$(COMMIT_SHA) \
		--build-arg COMMIT_VERSION=$(COMMIT_VERSION) \
		--compress \
		-t $3 .
	docker save $3 | gzip > $1/out/image.tar.gz
endef
