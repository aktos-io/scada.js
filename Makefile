.PHONY: all production clean

launch-broser:
	@firefox -new-tab -url http://localhost:4000 2>/dev/null &

#run-ide:
#	# this is fallback ide
#	echo '{"name": "aktos-webui", "files": [ { "directory": ".",  "recursive": 1 } ]}' > .kateproject
#	@kate .kateproject 2>/dev/null &


production-update:
	# build everything into ./public
	rm -r public 2> /dev/null & true
	sudo sh -c "ulimit -n 4096"; brunch b
	node preparse.js

	# if everything went ok, then update the public dir
	rm -rf server/public.bak 2> /dev/null & true
	mv server/public server/public.bak 2> /dev/null & true
	mv public server/

production-run-server:
	cd server; \
	pm2 delete server; \
	pm2 start server.ls --interpreter=lsc --watch --ignore-watch='public' --max-memory-restart=160M
	watch pm2 status

production-optimize:
	@echo "USE uglify to minimize javascripts..."



development-run-server:
	@echo "Starting server"
	cd server; \
	lsc server.ls

development-compile-watch:
	@echo "Starting to compile with brunch"
	@echo "---- DO NOT FORGET TO SET preparsed variable in app.ls!!! -----"
	mv server/public serve/public.bak 2> /dev/null; true
	ln -sf ../public server/
	brunch watch
