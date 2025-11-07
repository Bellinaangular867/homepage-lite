.PHONY: all build clean run test install uninstall restart status logs dev help update

# Variables
BINARY_NAME=homepage-lite
VERSION?=$(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
BUILD_TIME=$(shell date -u '+%Y-%m-%d_%H:%M:%S')
GIT_COMMIT=$(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
GO_VERSION=$(shell go version | awk '{print $$3}')

# Installation paths
INSTALL_PATH=/opt/homepage-lite
SERVICE_PATH=/etc/systemd/system
USER=homepage

# Ldflags
LDFLAGS=-ldflags "\
	-s -w \
	-X main.Version=$(VERSION) \
	-X main.BuildTime=$(BUILD_TIME) \
	-X main.GitCommit=$(GIT_COMMIT) \
	-X main.GoVersion=$(GO_VERSION)"

all: build ## Build the binary

build: ## Build the binary with ldflags
	@echo "Building $(BINARY_NAME) $(VERSION)..."
	@go build $(LDFLAGS) -o $(BINARY_NAME) .
	@echo "Build complete: ./$(BINARY_NAME)"

clean: ## Remove binary and artifacts
	@echo "Cleaning..."
	@rm -f $(BINARY_NAME)
	@go clean
	@echo "Clean complete"

run: build ## Build and run the application
	@echo "Running $(BINARY_NAME)..."
	@./$(BINARY_NAME)

dev: ## Run in development mode (reads files from disk, no embed)
	@echo "🚀 Starting development server..."
	@echo ""
	@go run -tags dev . --config config.yaml

test: ## Run tests
	@echo "Running tests..."
	@go test -v ./...

test-coverage: ## Run tests with coverage
	@echo "Running tests with coverage..."
	@go test -v -coverprofile=coverage.out ./...
	@go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report: coverage.html"

install: build ## Install to /opt/homepage-lite with systemd service
	@echo "Installing $(BINARY_NAME) to $(INSTALL_PATH)..."
	@if ! id $(USER) >/dev/null 2>&1; then \
		echo "Creating user $(USER)..."; \
		sudo useradd -r -s /bin/false $(USER); \
	fi
	@sudo mkdir -p $(INSTALL_PATH)
	@sudo cp $(BINARY_NAME) $(INSTALL_PATH)/
	@sudo chmod +x $(INSTALL_PATH)/$(BINARY_NAME)
	@if [ -f config.yaml ]; then \
		if [ ! -f $(INSTALL_PATH)/config.yaml ]; then \
			sudo cp config.yaml $(INSTALL_PATH)/; \
			sudo chown $(USER):$(USER) $(INSTALL_PATH)/config.yaml; \
		else \
			echo "⚠️  Config file already exists at $(INSTALL_PATH)/config.yaml - preserving existing configuration"; \
		fi; \
	fi
	@if [ -d static/dashboard-icons ]; then \
		sudo mkdir -p $(INSTALL_PATH)/static/dashboard-icons; \
		sudo cp -r static/dashboard-icons/* $(INSTALL_PATH)/static/dashboard-icons/ 2>/dev/null || true; \
		sudo chown -R $(USER):$(USER) $(INSTALL_PATH)/static; \
	fi
	@sudo chown -R $(USER):$(USER) $(INSTALL_PATH)
	@sudo cp homepage-lite.service $(SERVICE_PATH)/
	@sudo systemctl daemon-reload
	@sudo systemctl enable $(BINARY_NAME)
	@echo ""
	@echo "✅ Installation complete!"
	@echo ""
	@echo "Start service:"
	@echo "  sudo systemctl start $(BINARY_NAME)"
	@echo ""
	@echo "Check status:"
	@echo "  sudo systemctl status $(BINARY_NAME)"

uninstall: ## Uninstall from system
	@echo "Uninstalling $(BINARY_NAME)..."
	@sudo systemctl stop $(BINARY_NAME) 2>/dev/null || true
	@sudo systemctl disable $(BINARY_NAME) 2>/dev/null || true
	@sudo rm -f $(SERVICE_PATH)/$(BINARY_NAME).service
	@sudo systemctl daemon-reload
	@sudo rm -rf $(INSTALL_PATH)
	@echo ""
	@echo "✅ Uninstall complete!"
	@echo ""
	@echo "To remove user: sudo userdel $(USER)"

restart: ## Restart systemd service
	@sudo systemctl restart $(BINARY_NAME)
	@echo "Service restarted"

status: ## Show systemd service status
	@sudo systemctl status $(BINARY_NAME)

logs: ## Follow systemd service logs
	@sudo journalctl -u $(BINARY_NAME) -f

fmt: ## Format Go code
	@echo "Formatting code..."
	@go fmt ./...

vet: ## Run go vet
	@echo "Running go vet..."
	@go vet ./...

lint: ## Run golangci-lint (if installed)
	@if command -v golangci-lint >/dev/null 2>&1; then \
		echo "Running golangci-lint..."; \
		golangci-lint run; \
	else \
		echo "golangci-lint not installed, skipping..."; \
	fi

deps: ## Download dependencies
	@echo "Downloading dependencies..."
	@go mod download
	@go mod tidy

version: ## Show version information
	@echo "Version:    $(VERSION)"
	@echo "BuildTime:  $(BUILD_TIME)"
	@echo "GitCommit:  $(GIT_COMMIT)"
	@echo "GoVersion:  $(GO_VERSION)"

update: ## Update production installation (build, stop, install, restart)
	@echo "🔄 Updating $(BINARY_NAME)..."
	@echo "1️⃣  Building..."
	@$(MAKE) build
	@echo "2️⃣  Stopping service..."
	@sudo systemctl stop $(BINARY_NAME) 2>/dev/null || true
	@echo "3️⃣  Installing..."
	@$(MAKE) install
	@echo "4️⃣  Starting service..."
	@sudo systemctl start $(BINARY_NAME)
	@echo ""
	@echo "✅ Update complete!"
	@echo ""
	@echo "Check status:"
	@echo "  sudo systemctl status $(BINARY_NAME)"

help: ## Show this help message
	@echo "$(BINARY_NAME) - Makefile commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
