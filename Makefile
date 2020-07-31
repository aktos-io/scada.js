test:
	npm run test

interactive-update:
	npm run interactive-update

update-app-version:
	touch app-version.json

production:
	gulp --production --webapp $(APP_NAME)

development:
	gulp --webapp $(APP_NAME)
