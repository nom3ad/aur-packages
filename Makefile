

build:
	@set -e; \
	if [[ -z $$pkg ]]; then \
		select pkg in $$(find . -maxdepth 1 -type d  ! -name '.*' -printf '%f\n'); do \
			break;\
		done; \
	fi; \
	cd $$pkg && makepkg $$args

build-install:
	make build args="--install"

aur-publish:
	@set -e; \
	if [[ -z $$pkg ]]; then \
		select pkg in $$(find . -maxdepth 1 -type d  ! -name '.*' -printf '%f\n'); do \
			break;\
		done; \
	fi; \
	./aurpublish $$pkg