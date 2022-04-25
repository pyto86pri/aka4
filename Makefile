REVISION := $(shell git rev-parse --short HEAD)
ACCOUNT_ID := $(shell aws sts get-caller-identity | jq -r .Account)
REGION := ap-northeast-1
REPOSITORY := $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com
APP := aka4

.PHONY: build
build:
	docker build -t $(REPOSITORY)/$(APP):$(REVISION) .

.PHONY: push
push:
	aws ecr get-login-password --region $(REGION) | docker login --username AWS --password-stdin $(REPOSITORY)
	docker push $(REPOSITORY)/$(APP):$(REVISION)

.PHONY: run
run:
	docker run -p 9000:8080 $(REPOSITORY)/$(APP):$(REVISION)

.PHONY: e2e-test
test:
	curl -XPOST http://localhost:9000/2015-03-31/functions/function/invocations

.PHONY: plan
plan:
	terraform plan -var revision=$(REVISION)

.PHONY: apply
apply:
	terraform apply -var revision=$(REVISION)
