VENV_NAME := nodeenv

test:
	npm run test

update-deps:
	npm run interactive-update

update-app-version:
	touch lib/app-version.json

production: __production test

__production:
	@echo "Production build for APP: $${APP:?}"
	gulp --production --webapp $(APP)

development:
	@echo "Development build for APP: $${APP:?}"
	gulp --webapp $(APP)

update-scadajs:
	./tools/update-scadajs.sh

install-deps:
	@echo "Using configuration file: $${CONF:?}"
	./tools/install-modules.sh $(CONF)

get-deps-size:
	find . -name "node_modules" -type d -prune | xargs du -chs

clean-node-modules:
	find . -name "node_modules" -type d -prune -exec rm -rf '{}' +

clean:
	rm -rf ./build

freeze-venv:
	freeze ./nodeenv.txt

create-venv:
	$(eval NODE_VERSION := $(shell echo `grep "^#node@" nodeenv.txt | cut -d@ -f2` | sed 's/^$$/system/'))
	nodeenv --requirement=./nodeenv.txt --node=$(NODE_VERSION) --jobs=4 $(VENV_NAME)

