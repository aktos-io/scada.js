VENV_NAME := scadajs1
.PHONY: release test update-deps update-app-version

test:
	npm run test

update-deps:
	npm run interactive-update

update-app-version:
	touch lib/app-version.json

production: __production test release

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

clean-all: clean clean-node-modules

freeze-venv:
	freeze ./requirements.txt

create-venv:
	$(if $(value $(SCADAJS_1_ENV)),,$(error SCADAJS_1_ENV variable is set, use it instead: $(SCADAJS_1_ENV)))
	$(eval NODE_VERSION := $(shell echo `grep "^#node@" $(VENV_NAME).env | cut -d@ -f2` | sed 's/^$$/system/'))
	nodeenv --requirement=./$(VENV_NAME).env --node=$(NODE_VERSION) --jobs=4 $(VENV_NAME)
	mv $(VENV_NAME) nodeenv

release:
	@echo "Creating release for APP: $${APP:?}"
	( if [ ! -d release/$(APP) ]; then \
		 	mkdir -p release; \
			cd release; \
			git init $(APP); \
		fi \
	)
	rsync -a build/$(APP)/ release/$(APP)/
	( cd release/$(APP) && git add . && git commit )

