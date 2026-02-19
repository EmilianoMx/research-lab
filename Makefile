.PHONY: help validate

help:
	@echo "Available targets:"
	@echo "  make validate   - Validate docs links and citation metadata"

validate:
	python3 scripts/validate_repo.py
