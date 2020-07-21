FROM atlassian/jira-software:${_BUILD_VERSION}

ARG MYSQL_CONNECTOR_VERSION=5.1.49

RUN mkdir -p /tmp/mysql-connector \
    && curl -s https://cdn.mysql.com//Downloads/Connector-J/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.tar.gz \
        | tar -xz --strip-components=1 -C /tmp/mysql-connector \
    && mv /tmp/mysql-connector/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar ${JIRA_INSTALL_DIR}/lib/ \
    && rm -rf /tmp/mysql-connector \
    && chown ${RUN_USER}:${RUN_GROUP} ${JIRA_INSTALL_DIR}/lib/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar
