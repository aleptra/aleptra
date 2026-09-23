.PHONY: update push

update:
	git submodule sync --recursive
	git submodule update --init --recursive --remote

push:
	@set -e; \
	for path in $$(git config --file .gitmodules --get-regexp '^submodule\..*\.path$$' | awk '{print $$2}'); do \
		echo "Pushing $$path"; \
		if ! git -C "$$path" rev-parse --verify HEAD >/dev/null 2>&1; then \
			echo "Creating initial commit in $$path"; \
			git -C "$$path" add .; \
			git -C "$$path" commit --allow-empty --allow-empty-message -m ""; \
		elif ! git -C "$$path" diff --quiet HEAD 2>/dev/null || [ -n "$$(git -C "$$path" status --porcelain)" ]; then \
			git -C "$$path" add .; \
			git -C "$$path" commit --allow-empty-message -m ""; \
		fi; \
		if ! git ls-files --stage "$$path" | grep -q '^160000'; then \
			name=$$(git config --file .gitmodules --get-regexp '^submodule\..*\.path$$' | awk -v p="$$path" '$$2 == p {print $$1}' | sed 's/\.path$$//'); \
			url=$$(git config --file .gitmodules --get "$$name.url"); \
			echo "Registering $$path"; \
			git submodule add --force "$$url" "$$path"; \
		fi; \
		git -C "$$path" push -u origin HEAD:main; \
	done; \
	git add .; \
	if ! git diff --cached --quiet; then \
		git commit --allow-empty-message -m ""; \
	fi; \
	git push origin main