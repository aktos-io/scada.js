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
	ulimit -n 4096
	@brunch b && brunch w

run-server:
	@lsc server/server.ls

run-production-server:
	npm run server

update-production:
	sudo sysctl -w fs.inotify.max_user_watches=100000
	git pull
	if [ ! -d "server/public.to-remove-1" ]; then \
		mv server/public server/public.to-remove-1; \
		mv public server; \
	fi;
	brunch b
	mv server/public server/public.to-remove-2
	ln -s ../public server
	rm -rf server/public.to-remove-1 2> /dev/null; true
	rm -rf server/public.to-remove-2 2> /dev/null; true
