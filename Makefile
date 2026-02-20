.PHONY: help validate serve-ui

help:
	@echo "Available targets:"
	@echo "  make validate   - Validate docs links and citation metadata"
	@echo "  make serve-ui   - Launch local UI at http://localhost:8000/ui/"

validate:
	python3 scripts/validate_repo.py

serve-ui:
	python3 -m http.server 8000
