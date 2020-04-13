# cd installation-ocp-pipelines
# chmod 777 ./install.sh
# ./install.sh
# cd ..

oc new-project workshop-$GITHUB_USER

if [ ! -d "spring-rest-tekton-pipeline" ] 
then

    echo "Directory DOES NOT exist, cloning repo" 
    git clone https://github.com/$GITHUB_USER/spring-rest-tekton-pipeline.git

else

    git pull origin master
fi

oc project workshop