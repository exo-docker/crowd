#!/bin/bash
TOMCAT_LOCATION=/opt/${SOFTWARE_NAME}/apache-tomcat

start() {
  # Ensure the the volume home has the correct permissions, because this can cause errors
  chown ${SOFTWARE_NAME}:${SOFTWARE_NAME} -R /opt/${SOFTWARE_NAME}-home
  exec su-exec ${SOFTWARE_NAME} ${TOMCAT_LOCATION}/bin/catalina.sh run
}
