#!/usr/bin/env bash

set -e

run() {
  local jenkinsfile="${1}"
  local plugins="${2}"
  local scmfile="${3}"
  local command="${4}"

  if [[ ! -f ${jenkinsfile} ]]; then
      echo "jenkinsfile ${jenkinsfile} doesnt exist"
      exit 1
  fi

  if [[ ! -f ${plugins} ]]; then
      echo "pluginstxt ${plugins} doesnt exist"
      exit 1
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
  echo "/app/bin/jenkinsfile-runner ${command} --war /app/jenkins-${JENKINS_VERSION} --file=${jenkinsfile} --plugins=/usr/share/jenkins/ref/plugins"
  if [[ -f ${scmfile} ]]; then
      echo "scmfile ${scmfile} detected"
      cat ${scmfile}
      /app/bin/jenkinsfile-runner ${command} -w=/app/jenkins-${JENKINS_VERSION} --file=${jenkinsfile} --plugins=/usr/share/jenkins/ref/plugins --scm=${scmfile}
  else
      echo "scmfile not found. Generate scmfile.yaml with Github Actions..."
      touch scmfile.yaml
      
      password=$(yq '.credential.usernamePassword.password // "" ' scmfile.yaml) 
      username=$(yq '.credential.usernamePassword.username // "" ' scmfile.yaml) 
      url=$(yq '.scm.git.userRemoteConfig.url // "" ' scmfile.yaml) 
      branchName=$(yq '.scm.git.branches.url // "" ' scmfile.yaml)
      
      if [ "$password" != "${{ secrets.GITHUB_TOKEN }}" ] 
      then
        yq -i '.credential.usernamePassword.password = "${{ secrets.GITHUB_TOKEN }}"' scmfile.yaml
      fi
      if [ "$username" != "${{ github.actor }}" ] 
      then 
        yq -i '.credential.usernamePassword.username = "${{ github.actor }}"' scmfile.yaml
      fi
      if [ "$url" != "${{ github.repositoryUrl }}" ] 
      then 
        yq -i '.scm.git.userRemoteConfig.url = "${{ github.repositoryUrl }}"' scmfile.yaml
      fi
      if [ "$branchName" != "${{ github.ref_name }}" ] 
      then 
        yq -i '.scm.git.branches = "${{ github.ref_name }}"' scmfile.yaml
      fi
      cat scmfile.yaml
      /app/bin/jenkinsfile-runner ${command} -w=/app/jenkins-${JENKINS_VERSION} --file=${jenkinsfile} --plugins=/usr/share/jenkins/ref/plugins --scm=scmfile.yaml
  fi
}

run "${1}" "${2}" "${3}" "${4}"
