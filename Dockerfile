FROM eclipse-temurin:21.0.2_13-jre
LABEL maintainer="Igor Kolomiyets <igor.kolomiyets@iktech.io>"

RUN apt-get update -y
RUN apt-get install curl zip -y
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install nodejs
RUN apt-get upgrade -y

ARG SONARQUBE_SCANNER_VERSION=5.0.1.3006

WORKDIR /opt
RUN wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONARQUBE_SCANNER_VERSION}-linux.zip
RUN unzip sonar-scanner-cli-${SONARQUBE_SCANNER_VERSION}-linux.zip
RUN rm sonar-scanner-cli-${SONARQUBE_SCANNER_VERSION}-linux.zip
RUN ln -s sonar-scanner-${SONARQUBE_SCANNER_VERSION}-linux sonar-scanner
RUN mkdir -p /opt/sonar-scanner/conf
ADD sonar-scanner.properties /opt/sonar-scanner/conf

VOLUME /opt/sonar-scanner/conf

