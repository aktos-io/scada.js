test:
	npm run test

update-dependencies:
	npm run interactive-update

update-app-version:
	touch app-version.json

production:
	gulp --production --webapp $(APP)

development:
	gulp --webapp $(APP)

update-scadajs:
	./tools/update-scadajs.sh

install-dependencies:
	./tools/install-modules.sh $(conf)

get-dependency-size:
	find . -name "node_modules" -type d -prune | xargs du -chs

clean-node-dependencies:
	find . -name "node_modules" -type d -prune -exec rm -rf '{}' +

clean:
	rm -rf ./build
