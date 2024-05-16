tools:
	@printf '%s' '["downloader", "shuffler"]'
.PHONY:

lint:
	npx eslint .
.PHONY: lint

lint-fix:
	npx eslint --fix .
.PHONY: lint-fix

unit-test:
	@echo "No tests yet"
.PHONY: unit-test
