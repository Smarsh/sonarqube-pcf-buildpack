#!/bin/sh

echo "-----> Making java available"
export PATH=$PATH:/home/vcap/app/.java/bin

echo "-----> Setting sonar.properties"
export SONARQUBE_JDBC_USERNAME=`node getCreds.js username`
export SONARQUBE_JDBC_PASSWORD=`node getCreds.js password`
export SONARQUBE_JDBC_URL=`node getCreds.js jdbcUrl`
# mySQL doesn't like the url unless it has the appended parameters
export SONARQUBE_JDBC_URL="$SONARQUBE_JDBC_URL&useUnicode=true&characterEncoding=utf8"

echo "HERE ARE THE VCAP VARS SONARQUBE_JDBC_USERNAME=$SONARQUBE_JDBC_USERNAME SONARQUBE_JDBC_PASSWORD=$SONARQUBE_JDBC_PASSWORD SONARQUBE_JDBC_URL=$SONARQUBE_JDBC_URL"

echo "       sonar.web.port=${SONARQUBE_PORT}"
echo "\n ------- The following properties were automatically created by the buildpack -----\n" >> ./sonar.properties
echo "sonar.web.port=${SONARQUBE_PORT}\n" >> ./sonar.properties

# Replace all environment variables with syntax ${MY_ENV_VAR} with the value
# thanks to https://stackoverflow.com/questions/5274343/replacing-environment-variables-in-a-properties-file
perl -p -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg; s/\$\{([^}]+)\}//eg' ./sonar.properties > ./sonar_replaced.properties
mv ./sonar_replaced.properties ./sonar.properties

echo "------------------------------------------------------" > /home/vcap/app/sonarqube/logs/sonar.log

echo "-----> Starting SonarQube"

/home/vcap/app/sonarqube/bin/linux-x86-64/sonar.sh start

echo "-----> Tailing log"
sleep 10 # give it a bit of time to create files
cd /home/vcap/app/sonarqube/logs
tail -f ./sonar.log ./es.log ./web.log ./ce.log ./access.log
