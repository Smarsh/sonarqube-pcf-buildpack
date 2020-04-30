#!/bin/sh

echo "-----> Making java available"
export PATH=$PATH:/home/vcap/app/.java/bin

echo "-----> Setting sonar.properties"
vcap_username=`echo $VCAP_SERVICES | jq '.["p.mysql"][]["credentials"]["username"]'`
vcap_password=`echo $VCAP_SERVICES | jq '.["p.mysql"][]["credentials"]["password"]'`
vcap_jdbc_url=`echo $VCAP_SERVICES | jq '.["p.mysql"][]["credentials"]["jdbcUrl"]'`

#------------------------------------------
# Drop the " at the beginning and end of the variable
#------------------------------------------

vcap_jdbc_url="${vcap_jdbc_url%?}"
vcap_jdbc_url="${vcap_jdbc_url#?}"
# mySQL doesn't like the url unless it has the appended parameters
vcap_jdbc_url="${vcap_jdbc_url}&useUnicode=true&characterEncoding=utf8"
export SONARQUBE_JDBC_URL=$vcap_jdbc_url

vcap_username="${vcap_username%?}"
vcap_username="${vcap_username#?}"
export SONARQUBE_JDBC_USERNAME=$vcap_username

vcap_password="${vcap_password%?}"
vcap_password="${vcap_password#?}"
export SONARQUBE_JDBC_PASSWORD=$vcap_password


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
