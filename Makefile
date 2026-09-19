.PHONY: push

push:
	git -C admin add .
	@if git -C admin diff --cached --quiet; then \
		echo "No changes in admin"; \
	else \
		git -C admin commit --allow-empty-message -m ""; \
	fi
	git -C admin push origin HEAD:main

	git submodule foreach --recursive 'git push origin HEAD:main'

	git add .
	@if git diff --cached --quiet; then \
		echo "No changes in parent repository"; \
	else \
		git commit --allow-empty-message -m ""; \
	fi
	git push origin main