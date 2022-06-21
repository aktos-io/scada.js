DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

include $(DIR)/venv-version.txt
VENV_NAME := $(VENV_NAME)
$(eval VENV_PATH := $(shell echo "$$$(VENV_VERSION)"))
APP := main
CONFIG := ../dcs-modules.txt

__test_variables:
	@echo $(VENV_VERSION) path is set to $(VENV_PATH)

.PHONY: test-es6-compat update-deps update-app-version

# Check if we are in a VIRTUAL_ENV:
__c:
	$(if $(NODE_VIRTUAL_ENV),,$($(warning ************  WARNING: NOT INSIDE A VIRTUAL ENV  ************)))

__app: # Check if APP name is set
	$(if $(APP),,$($(error *** APP variable is not set. ***)))

test-es6-compat: __c
	es-check es6 './release/$(APP)/**/*.js'

update-deps: __c
	npm run interactive-update

update-app-version:
	touch lib/app-version.json

# Skip es-check with "make release ES_CHECK=skip
ifeq ($(ES_CHECK),skip)
release: __c __prepare_release_dir __production  __release_commit
else
release: __c __prepare_release_dir __production test-es6-compat __release_commit
endif

__production: __app
	gulp --webapp $(APP) --production

development: __c __app
	@tmux rename-window "gulp" 2> /dev/null || true
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
	$(if $(VENV_PATH),$(error $(VENV_VERSION) variable is set, use it instead: $(VENV_PATH)))
	$(eval NODE_VERSION := $(shell echo `grep "^#node@" nodeenv.txt | cut -d@ -f2` | sed 's/^$$/system/'))
	nodeenv --requirement=./nodeenv.txt --node=$(NODE_VERSION) --prompt="($(VENV_NAME))" --jobs=4 nodeenv

use-venv:
	./venv

__prepare_release_dir:
	@( if [ ! -d release/$(APP) ]; then \
		 	mkdir -p release; \
			cd release; \
			git init $(APP); \
		fi \
	)

__release_commit:
	( cd release/$(APP) && git add . && git commit -m "unattended commit")

release-push:
	@( cd release/$(APP) && git push )

list-modules:
	@find . -name package.json -and -not -path "*/node_modules/*" | xargs dirname | sort

npm-audit-all:
	@$(MAKE) list-modules --no-print-directory | xargs -I '{}' bash -c \
	'cd {}; echo -e "-----------\nAudit for {}:\n-----------\n\n"; npm i --package-lock-only; npm audit'
