# Superplan verify gate
# verify = lint + test + pack-check (build)
#
# Install hooks once: make install-hooks

SHELLCHECK ?= shellcheck

.PHONY: help lint test build verify fmt clean install-hooks

help:
	@echo "Targets:"
	@echo "  make verify        - lint + test + pack-check (default gate; CI / lefthook)"
	@echo "  make lint          - shellcheck install.sh tests/*.sh scripts/*.sh"
	@echo "  make test          - tests/run.sh (fake HOME)"
	@echo "  make build         - pack-check skills/*/SKILL.md"
	@echo "  make fmt           - shfmt -w if installed"
	@echo "  make clean         - remove tmp/"
	@echo "  make install-hooks - lefthook install (pre-commit → make verify)"

lint:
	@command -v $(SHELLCHECK) >/dev/null 2>&1 || { echo "lint: shellcheck not installed"; exit 1; }
	@test -f install.sh || { echo "lint: install.sh missing (T01)"; exit 1; }
	$(SHELLCHECK) -x install.sh
	@for f in tests/*.sh scripts/*.sh; do \
		if [ -f "$$f" ]; then $(SHELLCHECK) -x "$$f"; fi; \
	done

test:
	@test -f tests/run.sh || { echo "test: tests/run.sh missing (T01)"; exit 1; }
	@chmod +x tests/run.sh
	./tests/run.sh

build:
	@test -f scripts/pack-check.sh || { echo "build: scripts/pack-check.sh missing (T01)"; exit 1; }
	@chmod +x scripts/pack-check.sh
	./scripts/pack-check.sh

verify: lint test build

fmt:
	@command -v shfmt >/dev/null 2>&1 && shfmt -w install.sh tests scripts || true

clean:
	rm -rf tmp/

install-hooks:
	lefthook install
