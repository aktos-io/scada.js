DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

APP := main
CONFIG := $(DIR)../dcs-modules.txt

.PHONY: test-es6-compat update-deps update-app-version

# Check if we are in a VIRTUAL_ENV:
# the `NODE_VIRTUAL_ENV` variable is set by nodeenv after activating the environment.
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
ifndef SCADAJS_VENV_PATH
	$(error SCADAJS_VENV_PATH can not be empty. Please provide an installation path to create a venv.)
endif
ifneq ($(wildcard $(SCADAJS_VENV_PATH)/.*),)
	$(error SCADAJS_VENV_PATH is already created, use that instead: $(SCADAJS_VENV_PATH)))
endif
	$(eval VENV_NAME := $(shell basename $(SCADAJS_VENV_PATH)))
	$(eval NODE_VERSION := $(shell echo `grep "^#node@" nodeenv.txt | cut -d@ -f2` | sed 's/^$$/system/'))
	nodeenv --requirement=./nodeenv.txt --node=$(NODE_VERSION) --prompt="($(VENV_NAME))" --jobs=4 $(SCADAJS_VENV_PATH)

use-venv:
	./venv

update-venv:
	@echo "Virtual environment should not be updated. Create a new virtual environment"
	@echo "with the new dependency versions and use that venv instead. If there is no "
	@echo "breaking changes, simply backup the old venv and replace the new venv with "
	@echo "the old one. This is the safest path to follow."

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
