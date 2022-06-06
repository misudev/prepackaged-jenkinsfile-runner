#!/usr/bin/env bash

set -e

run() {
  local jenkinsfile="${1}"
  local plugins="${2}"
  local scmfile="${3}"
  local command="${4}"

  if [[ ! -f ${jenkinsfile} ]]; then
      echo "jenkinsfile ${jenkinsfile} does not exist"
      exit 1
  fi

  if [[ ! -f ${plugins} ]]; then
      echo "pluginstxt ${plugins} does not exist"
      exit 1
  fi
  
  if [[ ! -f ${scmfile} ]]; then
      echo "scmfile ${scmfile} does not exist."
  fi

  
  plugin_manager_ver=$(java -jar /app/bin/jenkins-plugin-manager.jar --version)
  runner_ver=$(/app/bin/jenkinsfile-runner-launcher --version)
  echo $(ls /app)
  echo "jenkins-plugin-manager: ${plugin_manager_ver}"
  echo "jenkinsfile-runner: ${runner_ver}"
  
  echo
  ls -lrt /usr/share/jenkins/ref/plugins
  echo
  echo "java -jar /app/bin/jenkins-plugin-manager.jar --war /app/jenkins-${JENKINS_VERSION}.war --plugin-file ${plugins} --plugin-download-directory=/usr/share/jenkins/ref/plugins"
  java -jar /app/bin/jenkins-plugin-manager.jar --war /app/jenkins-${JENKINS_VERSION}.war --plugin-file ${plugins} --plugin-download-directory=/usr/share/jenkins/ref/plugins
  echo
  if [[ ! -f ${scmfile} ]]; then
      echo "scmfile ${scmfile} does not exist."
      echo "/app/bin/jenkinsfile-runner ${command} --war /app/jenkins-${JENKINS_VERSION} --file=${jenkinsfile} --plugins=/usr/share/jenkins/ref/plugins"
      /app/bin/jenkinsfile-runner ${command} --war /app/jenkins-${JENKINS_VERSION} --file=${jenkinsfile} --plugins=/usr/share/jenkins/ref/plugins
  else
      echo "/app/bin/jenkinsfile-runner ${command} --war /app/jenkins-${JENKINS_VERSION} --file=${jenkinsfile} --plugins=/usr/share/jenkins/ref/plugins --scm ${scmfile}"
      cat ${scmfile}
      /app/bin/jenkinsfile-runner ${command} -w=/app/jenkins-${JENKINS_VERSION} --file=${jenkinsfile} --plugins=/usr/share/jenkins/ref/plugins --scm ${scmfile}  
  fi
}

run "${1}" "${2}" "${3}" "${4}"
