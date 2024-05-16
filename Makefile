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

trigger:
	@TOOL="$$(make tools | jq -rc '.[]' | fzf --prompt 'Trigger tool: ')"; \
	test -n "$$TOOL" || exit 1; \
	\
	date > "$$TOOL/.trigger" || exit 1; \
	git add "$$TOOL/.trigger"
.PHONY: trigger
