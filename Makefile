
build:
	@set -e; \
	if [[ -z $$pkg ]]; then \
		select pkg in $$(find . -maxdepth 1 -type d  ! -name '.*' -printf '%f\n'); do \
			break;\
		done; \
	fi; \
	cd "$$pkg"; \
	pkgver=$$(grep "^pkgver=" PKGBUILD | cut -d'=' -f2); \
	pkgrel=$$(grep "^pkgrel=" PKGBUILD | cut -d'=' -f2); \
	pkgname=$$(grep "^pkgname=" PKGBUILD | cut -d'=' -f2); \
	pkgfile=$$pkgname-$$pkgver-$$pkgrel-$$(uname -m).pkg.tar.zst; \
	makepkg -f $$args; \
	ls -alh $$pkgfile; \
	cd -; \
	make mksrcinfo pkg=$$pkg; \
	read -r -p "Do you want to install $$pkg? [y/N] " && [[ $$REPLY =~ ^[Yy]$$ ]] && sudo pacman -U $$pkg/$$pkgfile; \
	read -r -p "Do you want to publish $$pkg? [y/N] " && [[ $$REPLY =~ ^[Yy]$$ ]] && make publish pkg=$$pkg

quick-build-install:
	@set -e; \
	if [[ -z $$pkg ]]; then \
		select pkg in $$(find . -maxdepth 1 -type d  ! -name '.*' -printf '%f\n'); do \
			break;\
		done; \
	fi; \
	cd "$$pkg"; \
	makepkg --skipinteg --install -f 

show-sha256sum:
	@set -e -o pipefail; \
	cd "$$pkg"; \
	. ./PKGBUILD; \
	declare -a sha256sums; \
	i=0; \
	block=; \
	for src in "$${source[@]}"; do \
			block="$$block'$$(sha256sum $$src | cut -d' ' -f1)'"$$'\n'; \
	done; \
	echo -e "$$block"

geninteg:
	@cd "$$pkg" && makepkg --geninteg $$args

mksrcinfo:
	@cd "$$pkg"; \
	pkgver=$$(grep "^pkgver=" PKGBUILD | cut -d'=' -f2); \
	pkgrel=$$(grep "^pkgrel=" PKGBUILD | cut -d'=' -f2); \
	pkgname=$$(grep "^pkgname=" PKGBUILD | cut -d'=' -f2); \
	pkgfile=$$pkgname-$$pkgver-$$pkgrel-$$(uname -m).pkg.tar.zst; \

build-install:
	@make build args="--install"

publish:
	@./aurpublish.sh $$pkg