
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

geninteg:
	cd "$$pkg" && makepkg --geninteg $$args

mksrcinfo:
	cd "$$pkg" && makepkg --printsrcinfo > .SRCINFO

build-install:
	make build args="--install"

publish:
	./aurpublish.sh $$pkg