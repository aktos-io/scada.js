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
	firefox -new-tab -url http://localhost:4000

run-ide:
	@kate .kateproject 2>/dev/null &
run-brunch:
	@brunch b && brunch w
run-server:
	lsc server/server.ls
