.PHONY: all production clean

PRODUCTION_FOLDER := production

production: clean
	rm -r public 2> /dev/null & true
	mkdir $(PRODUCTION_FOLDER)
	brunch build --production
	mv public/ $(PRODUCTION_FOLDER)
	lsc -o $(PRODUCTION_FOLDER) -c server/server.ls

clean:
	rm -r $(PRODUCTION_FOLDER) 2> /dev/null & true
