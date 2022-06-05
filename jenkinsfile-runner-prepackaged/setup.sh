#!/usr/bin/env bash

set -e

run() {
  runner_ver=$(/app/bin/jenkinsfile-runner --version)
  echo "jenkins-plugin-manager: $(java -jar /app/bin/jenkins-plugin-manager.jar --version)"
#   java -jar /app/bin/jenkins-plugin-manager.jar --help

  echo
  rm -rf /usr/share/jenkins/ref/plugins
  rm -rf /app/jenkins

  echo
  echo "Exploding /app/jenkins-${JENKINS_VERSION}.war to /app/jenkins-${JENKINS_VERSION}"
  unzip /app/jenkins-${JENKINS_VERSION}.war -d /app/jenkins-${JENKINS_VERSION}
#   mkdir -p /usr/share/jenkins/ref/plugins
  echo
  echo "java -jar /app/bin/jenkins-plugin-manager.jar --war /app/jenkins-${JENKINS_VERSION}.war --plugin-file /app/setup/plugins.txt --plugin-download-directory=/usr/share/jenkins/ref/plugins"
  java -jar /app/bin/jenkins-plugin-manager.jar --war /app/jenkins-${JENKINS_VERSION}.war --plugin-file /app/setup/plugins.txt --plugin-download-directory=/usr/share/jenkins/ref/plugins

  echo
  ls -lrt /usr/share/jenkins/ref/plugins

  echo
  echo "/app/bin/jenkinsfile-runner lint -w=/app/jenkins-${JENKINS_VERSION} --file=/app/setup/Jenkinsfile-helloworld --plugins=/usr/share/jenkins/ref/plugins"
  /app/bin/jenkinsfile-runner lint -w=/app/jenkins-${JENKINS_VERSION} --file=/app/setup/Jenkinsfile-helloworld --plugins=/usr/share/jenkins/ref/plugins

  echo
  echo "/app/bin/jenkinsfile-runner run -w=/app/jenkins-${JENKINS_VERSION} --file=/app/setup/Jenkinsfile-helloworld --plugins=/usr/share/jenkins/ref/plugins"
  /app/bin/jenkinsfile-runner run -w=/app/jenkins-${JENKINS_VERSION} --file=/app/setup/Jenkinsfile-helloworld --plugins=/usr/share/jenkins/ref/plugins
}

run "${1}" "${2}"
