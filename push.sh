echo "Please enter a commit message: "
read msg
echo "Compiling assets...."
rake assets:precompile
git add -A
git commit -m "$msg"
echo "pushing to git..."
git push
echo "pushing to heroku"
heroku git:remote -a sixdegfrancisbacon
git push heroku master
echo "push complete! :)"
#This script automatically pushes changes to git and heroku!
#Written by Jeremy Lee 2015