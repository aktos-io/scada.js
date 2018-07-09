# Deploying to Github Pages

> Recommended as Github Pages support SSL by default

1. (Optional) Create a new repository (eg. mypublish)
2. Create `docs` folder
3. `cp -a ProjectRoot/scada.js/build/mywebapp/* /path/to/mypublish/docs`
4. `git push`
5. Enable Github Pages for /docs folder for Github/youruser/mypublish project.
6. Go to `https://youruser.github.io/mypublish`

# Deploying to surge.sh

1. (Optional) Put your domain name in ProjectRoot/webapps/mywebapp/assets/CNAME file:

        foo.surge.sh

2. `cd ProjectRoot/scada.js/build/mywebapp`
3. Publish your webapp: `surge`
4. Go to `foo.surge.sh`
