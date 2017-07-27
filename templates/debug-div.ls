``
            (function () {
                var old = console.log;
                var logger = document.getElementById('debugDiv');
                console.log = function () {
                  old.apply(this, arguments);
                  try {
                      for (var i = 0; i < arguments.length; i++) {
                        if (typeof arguments[i] == 'object') {
                            logger.innerHTML += (JSON && JSON.stringify ? JSON.stringify(arguments[i], undefined, 2) : arguments[i]) + '<br />';
                        } else {
                            logger.innerHTML += arguments[i] + '<br />';
                        }
                      }
                   }
                   catch(e) {
                   }
                }
            })();
``
