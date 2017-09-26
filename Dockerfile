# use base image
FROM ubuntu:16.04

MAINTAINER didlich <didlich@t-online.de>

# Set the WILDFLY_VERSION env variable
ENV WILDFLY_VERSION 8.2.1.Final
ENV JBOSS_PATH /opt/jboss
ENV JBOSS_HOME /opt/jboss/wildfly

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

## UTF-8 
RUN apt-get update \
    && apt-get install -y locales \
    && locale-gen en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8


## Remove any existing JDKs
RUN apt-get --purge remove openjdk*

RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections \
    && echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" > /etc/apt/sources.list.d/webupd8team-java-trusty.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 \
    && apt-get update \
    && apt-get install -y oracle-java8-installer wget tar \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/cache/oracle-jdk8-installer


#http://download.jboss.org/wildfly/8.2.1.Final/wildfly-8.2.1.Final.tar.gz

# Create a user and group used to launch processes
RUN mkdir -p $JBOSS_PATH \
    && groupadd -r jboss \
    && useradd -r -g jboss -s /sbin/nologin -c "JBoss user" jboss

# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
# Make sure the distribution is available from a well-known place

WORKDIR $JBOSS_PATH

RUN wget http://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz \
    && tar -zxvf wildfly-$WILDFLY_VERSION.tar.gz \
    && ln -s $JBOSS_PATH/wildfly-$WILDFLY_VERSION $JBOSS_HOME \
    && ${JBOSS_HOME}/bin/add-user.sh -u wildfly -p wildfly -s \
    && rm -rf wildfly-$WILDFLY_VERSION.tar.gz \
    && chown -R jboss:jboss $JBOSS_PATH/wildfly-$WILDFLY_VERSION \
    && chown -R jboss:jboss ${JBOSS_HOME} \
    && chmod -R g+rw ${JBOSS_HOME} \
    # data exchange folder
    && mkdir -p /opt/shared \
    && chmod -R g+rw ${JBOSS_HOME}

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

USER jboss

# Expose the ports we're interested in
EXPOSE 8080 9990

# Set the default command to run on boot
# This will boot WildFly in the standalone mode and bind to all interface
CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]

