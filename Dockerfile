FROM registry.redhat.io/devspaces/udi-rhel8

MAINTAINER Trevor Dolby <trevor.dolby@ibm.com> (@trevor-dolby-at-ibm-com)

# Build:
#
# docker build -t ace-dev-spaces-container:12.0.4.0 -f Dockerfile .

ARG DOWNLOAD_URL=http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/integration/12.0.4.0-ACE-LINUX64-DEVELOPER.tar.gz
ARG PRODUCT_LABEL=ace-12.0.4.0

ARG MQ_DOWNLOAD_URL=http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/messaging/mqdev/redist/9.3.1.0-IBM-MQC-Redist-LinuxX64.tar.gz


# Install ACE and accept the license
RUN mkdir /opt/ibm && \
    echo Downloading package ${DOWNLOAD_URL} && \
    curl ${DOWNLOAD_URL} | tar zx --exclude 'ace-12.0.*.0/tools' --directory /opt/ibm && \
    mv /opt/ibm/${PRODUCT_LABEL} /opt/ibm/ace-12 && \
    /opt/ibm/ace-12/ace make registry global accept license deferred

# Source profile automatically; requires LICENSE to be set to "accept"
# for the container to avoid errors.
RUN usermod -a -G mqbrkrs user \
  && echo ". /opt/ibm/ace-12/server/bin/mqsiprofile" >> /home/user/.bashrc \ 
  && echo ". /opt/ibm/ace-12/server/bin/mqsiprofile" >> /home/user/.profile

# OpenShift randomizes users so we need to chmod /var/mqsi; could be
# more restrictive . . . 
RUN chmod -R 777 /var/mqsi

# Install MQ client libraries
RUN mkdir /opt/mqm && curl ${MQ_DOWNLOAD_URL} | tar zx --exclude=tools --directory /opt/mqm
