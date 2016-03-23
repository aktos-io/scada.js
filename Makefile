.PHONY: all production clean

PRODUCTION_FOLDER := production

clean:
	rm -r $(PRODUCTION_FOLDER) 2> /dev/null & true

launch-browser:
	@firefox -new-tab -url http://localhost:4000 2>/dev/null &

run-ide:
	# this is fallback ide
	echo '{"name": "aktos-webui", "files": [ { "directory": ".",  "recursive": 1 } ]}' > .kateproject
	@kate .kateproject 2>/dev/null &

run-ide-atom:
	atom .



production-update:
	# build everything into ./public
	rm -r public 2> /dev/null & true 
	sudo sh -c "ulimit -n 4096"; brunch b
	node preparse.js
	
	# if everything went ok, then update the public dir 
	rm -r server/public.bak 2> /dev/null & true 
	mv server/public server/public.bak 2> /dev/null & true  
	mv public server/
	
production-run: 
	cd server; \
	pm2 delete server; \
	pm2 start server.ls --interpreter=lsc --watch --ignore-watch='public' --max-memory-restart=160M


