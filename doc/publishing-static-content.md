# Deploying to Github Pages

1. (Optional) Create a new repository (eg. mypublish)
2. Create `docs` folder
3. `cp -a ProjectRoot/scada.js/build/mywebapp/* /path/to/mypublish/docs`
4. `git push`
5. Enable Github Pages for /docs folder for Github/youruser/mypublish project.
6. Go to `https://youruser.github.io/mypublish`

# Deploying to surge.sh

1. (Recommended, one time) Put your domain name in `ProjectRoot/webapps/mywebapp/assets/CNAME` file:

       https://foo.surge.sh

2. Publish your webapp: 
       
       cd ProjectRoot/scada.js/build/mywebapp
       surge
       
3. Go to `https://foo.surge.sh`
