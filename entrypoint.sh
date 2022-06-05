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
      
      password=$(yq '.credential.usernamePassword.password // "" ' ${scmfile}) 
      username=$(yq '.credential.usernamePassword.username // "" ' ${scmfile}) 
      url=$(yq '.scm.git.userRemoteConfigs.url // "" ' ${scmfile}) 
      branchName=$(yq '.scm.git.branches // "" ' ${scmfile})
      if [ -z $password ]
      then
        yq -i '.credential.usernamePassword.password = "${{ secrets.GITHUB_TOKEN }}"' ${scmfile}
      fi
      if [ -z $username ]
      then 
        yq -i '.credential.usernamePassword.username = "${{ github.actor }}"' ${scmfile}
      fi
      if [ -z $url ]
      then 
        yq -i '.scm.git.userRemoteConfigs.url = "${{ github.repositoryUrl }}"' ${scmfile}
      fi
      if [ -z $branchName ]
      then 
        yq -i '.scm.git.branches = "${{ github.ref_name }}"' ${scmfile}
      fi
      cat ${scmfile}
      /app/bin/jenkinsfile-runner ${command} -w=/app/jenkins-${JENKINS_VERSION} --file=${jenkinsfile} --plugins=/usr/share/jenkins/ref/plugins --scm=${scmfile}
  else
      echo "scmfile not found. Generate scmfile.yaml with Github Actions..."
      touch scmfile.yaml
      
      yq -i '.credential.usernamePassword.password = "${{ secrets.GITHUB_TOKEN }}"' scmfile.yaml
      yq -i '.credential.usernamePassword.username = "${{ github.actor }}"' scmfile.yaml
      yq -i '.scm.git.userRemoteConfigs.url = "${{ github.repositoryUrl }}"' scmfile.yaml
      yq -i '.scm.git.branches = "${{ github.ref_name }}"' scmfile.yaml
      
      cat scmfile.yaml
      /app/bin/jenkinsfile-runner ${command} -w=/app/jenkins-${JENKINS_VERSION} --file=${jenkinsfile} --plugins=/usr/share/jenkins/ref/plugins --scm=scmfile.yaml
  fi
}

run "${1}" "${2}" "${3}" "${4}"
