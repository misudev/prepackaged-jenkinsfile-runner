FROM ghcr.io/jenkinsci/jenkinsfile-runner-github-actions/jenkinsfile-runner-prepackaged:latest

LABEL "com.github.actions.name"="Jenkinsfile Runner Prepackaged"
LABEL "com.github.actions.description"="Runs Jenkinsfile in a pre-packaged single-shot master"
LABEL "com.github.actions.icon"="battery"
LABEL "com.github.actions.color"="blue"

LABEL "repository"="https://github.com/inspirit941/prepackaged-jenkinsfile-runner"
LABEL "homepage"="http://github.com/actions"

# 
ENV JENKINS_VERSION=2.350

COPY Jenkinsfile-helloworld /app/setup/Jenkinsfile-helloworld
COPY base-plugins.txt /app/setup/plugins.txt

RUN curl -L http://updates.jenkins.io/download/war/${JENKINS_VERSION}/jenkins.war -o /app/jenkins-${JENKINS_VERSION}.war
RUN apt-get update && apt-get install -y zip git
RUN curl -fsSLO https://get.docker.com/builds/Linux/x86_64/docker-17.04.0-ce.tgz \
  && tar xzvf docker-17.04.0-ce.tgz \
  && mv docker/docker /usr/local/bin \
  && rm -r docker docker-17.04.0-ce.tgz

COPY setup.sh /app/setup/setup.sh
RUN /app/setup/setup.sh

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh" ]
