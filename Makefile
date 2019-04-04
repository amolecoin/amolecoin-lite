.DEFAULT_GOAL := help

.PHONY: build-js build-js-min test lint check install-linters format fix-amolecoin-dep help
.PHONY: test-js

build-js: ## Build /amolecoin/amolecoin.go. The result is saved in the repo root
	go build -o gopherjs-tool vendor/github.com/gopherjs/gopherjs/tool.go
	GOOS=linux ./gopherjs-tool build amolecoin/amolecoin.go

build-js-min: ## Build /amolecoin/amolecoin.go. The result is minified and saved in the repo root
	go build -o gopherjs-tool vendor/github.com/gopherjs/gopherjs/tool.go
	GOOS=linux ./gopherjs-tool build amolecoin/amolecoin.go -m

test-js: ## Run the Go tests using JavaScript
	go build -o gopherjs-tool vendor/github.com/gopherjs/gopherjs/tool.go
	./gopherjs-tool test ./amolecoin/ -v

test-suite-ts: ## Run the ts version of the cipher test suite. Use a small number of test cases
	npm run test

test-suite-ts-extensive: ## Run the ts version of the cipher test suite. All the test cases
	npm run test-extensive

test:
	go test ./... -timeout=10m -cover

lint: ## Run linters. Use make install-linters first.
	vendorcheck ./...
	gometalinter --deadline=3m -j 2 --disable-all --tests --exclude .. --vendor \
		-E goimports \
		-E unparam \
		-E deadcode \
		-E errcheck \
		-E gosec \
		-E goconst \
		-E gofmt \
		-E golint \
		-E ineffassign \
		-E maligned \
		-E megacheck \
		-E misspell \
		-E nakedret \
		-E structcheck \
		-E unconvert \
		-E varcheck \
		-E vet \
		./...

check: lint test ## Run tests and linters

install-linters: ## Install linters
	go get -u github.com/FiloSottile/vendorcheck
	go get -u github.com/alecthomas/gometalinter
	gometalinter --vendored-linters --install

format: ## Formats the code. Must have goimports installed (use make install-linters).
	goimports -w ./amolecoin
	goimports -w ./liteclient
	goimports -w ./mobile

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
