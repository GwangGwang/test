
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

build-events-image-dev:
	$(call build-image,cmd,app.dev.json,events)