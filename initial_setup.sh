#! /bin/sh

FILE=/home/pavel/docker_initialized
TEMP_DIR=/tmp/init_docker
JENKINS_HOME=/home/pavel/jenkins_home

if [ -e "$FILE" ]; then
    echo "Docker was already initialized... Leaving"
    exit 0
fi

echo "Go to temp folder"
# Better do check for its presence and exit

if [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
fi

mkdir "$TEMP_DIR"
cd "$TEMP_DIR"

echo "Load config files from github"
wget https://raw.githubusercontent.com/citizenof17/un_devops/master/Dockerfile-jenkins
wget https://raw.githubusercontent.com/citizenof17/un_devops/master/plugins.txt
wget https://raw.githubusercontent.com/citizenof17/un_devops/master/config.xml

echo "Clean docker leftovers"
docker container rm -f jenkins
docker rmi my_jenkins

echo "Build docker image for jenkins"
docker build -f Dockerfile-jenkins -t my_jenkins .

echo "Create and start jenkins container"
if [ ! -d "$JENKINS_HOME" ]; then
    echo "Create /home/pavel/jenkins_home"
    mkdir "$JENKINS_HOME"
    chmod a+w "$JENKINS_HOME"
fi
docker create --name jenkins --restart=always -p 8080:8080 -p 50000:50000 -v "$JENKINS_HOME":/var/jenkins_home my_jenkins
docker start jenkins

echo "Sleep and wait for jenkins (better poll its api, but nvm)"
sleep 45

echo "Load jenkins-cli"
wget http://localhost:8080/jnlpJars/jenkins-cli.jar

echo "Create job"
java -jar jenkins-cli.jar -s http://localhost:8080 create-job my_new_job < $TEMP_DIR/config.xml

echo "Jenkins intallation is finished!"
echo "Setting docker initialized file not to run this script in future"
touch "$FILE"
echo "1" > "$FILE"
echo "Done... Leaving"
