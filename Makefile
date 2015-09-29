.PHONY: all production clean

PRODUCTION_FOLDER := production

production: clean
	rm -r public 2> /dev/null & true
	mkdir $(PRODUCTION_FOLDER)
	DEBUG='brunch:*' brunch build --production
	mv public/ $(PRODUCTION_FOLDER)
	lsc -o $(PRODUCTION_FOLDER) -c server/server.ls

clean:
	rm -r $(PRODUCTION_FOLDER) 2> /dev/null & true

new-client:
	@firefox -new-tab -url http://localhost:4000 2>/dev/null &

run-ide:
	@#kate .kateproject 2>/dev/null &
	atom .
run-brunch:
	@brunch b && brunch w

run-server:
	@lsc server/server.ls

run-production-server:
	npm run server

update-production:
	git pull
	mv server/public server/public.to-remove-1
	mv public server
	brunch b
	mv server/public server/public.to-remove-2
	ln -s ../public server
	rm -r server/public.to-remove-1
	rm -r server/public.to-remove-2
