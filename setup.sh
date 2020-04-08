cd installation-ocp-pipelines
chmod 777 ./install.sh
./install.sh
cd ..

git clone https://github.com/paolocarta/spring-rest-tekton-pipeline.git

oc project workshop