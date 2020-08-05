VENV_NAME := scadajs1
.PHONY: release test update-deps update-app-version

# Check if we are in a VIRTUAL_ENV:
__c:
	$(if $(NODE_VIRTUAL_ENV),,$($(warning ************  WARNING: NOT INSIDE A VIRTUAL ENV  ************)))

__app: # Check if APP name is set
	$(if $(APP),,$($(error *** APP variable is not set. ***)))

test: __c
	es-check es5 './release/**/*.js'

update-deps: __c
	npm run interactive-update

update-app-version:
	touch lib/app-version.json

production: __c __production __release_copy test __release_commit

__production: __app
	gulp --webapp $(APP) --production

development: __c __app
	gulp --webapp $(APP)

update-scadajs:
	./tools/update-scadajs.sh

install-deps: __c
	@echo "Using configuration file: $${CONF:?}"
	./tools/install-modules.sh $(CONF)

get-deps-size:
	find . -name "node_modules" -type d -prune | xargs du -chs

clean-node-modules:
	find . -name "node_modules" -type d -prune -exec rm -rf '{}' +

clean-build:
	rm -rf ./build

clean-all: clean-build clean-node-modules

freeze-venv: __c
	freeze ./requirements.txt

create-venv:
	$(if $(value $(SCADAJS_1_ENV)),,$(error SCADAJS_1_ENV variable is set, use it instead: $(SCADAJS_1_ENV)))
	$(eval NODE_VERSION := $(shell echo `grep "^#node@" $(VENV_NAME).env | cut -d@ -f2` | sed 's/^$$/system/'))
	nodeenv --requirement=./$(VENV_NAME).env --node=$(NODE_VERSION) --jobs=4 $(VENV_NAME)
	mv $(VENV_NAME) nodeenv

__release_copy:
	@echo "Creating release for APP: $${APP:?}"
	( if [ ! -d release/$(APP) ]; then \
		 	mkdir -p release; \
			cd release; \
			git init $(APP); \
		fi \
	)
	rsync -a build/$(APP)/ release/$(APP)/

__release_commit:
	( cd release/$(APP) && git add . && git commit )
