IMAGE = boeboe/elk-f5-ts
TAG = 671

default: build push

build:
	docker build --pull -t ${IMAGE}:${TAG} --build-arg VERSION=${TAG} .
	docker tag ${IMAGE}:${TAG} ${IMAGE}:${TAG}
	docker tag ${IMAGE}:${TAG} ${IMAGE}:latest

build-clean:
	docker build --pull --no-cache -t ${IMAGE}:${TAG} --build-arg VERSION=${TAG} .
	docker tag ${IMAGE}:${TAG} ${IMAGE}:${TAG}
	docker tag ${IMAGE}:${TAG} ${IMAGE}:latest

push:
	docker push ${IMAGE}:${TAG}
	docker push ${IMAGE}:latest
