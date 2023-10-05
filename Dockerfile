# Base Image
FROM amazonlinux:2023

# Metadata
LABEL maintainer="Shane Holloman"
LABEL version="1.0"
LABEL description="Amazon Linux 2023 used with GitHub Actions for Ansible role testing. Not for production use!"
LABEL license="MIT"
LABEL vendor="Shane Holloman"
LABEL build-date="2023-09-27"
LABEL vcs-url="https://github.com/docker-amazonlinux2023-ansible"
LABEL documentation="https://github.com/docker-amazonlinux2023-ansible/README.md"

# Environment Variables
ENV container=docker
ENV pip_packages "ansible"

# Install systemd -- See https://hub.docker.com/_/centos/
RUN rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

# Install requirements
RUN yum -y install rpm dnf-plugins-core \
    && yum -y update \
    && yum -y install \
    initscripts \
    sudo \
    which \
    hostname \
    libyaml-devel \
    python3 \
    python3-pip \
    python3-pyyaml \
    && yum clean all

# Upgrade pip to latest version
#RUN pip3 install --upgrade pip

# Install Ansible via Pip
RUN pip3 install $pip_packages

# Remove the old setuptools
RUN yum -y remove python3-setuptools

# Install a secure version of setuptools via pip
RUN pip3 install setuptools

# Disable requiretty.
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers

# Install Ansible inventory file
RUN mkdir -p /etc/ansible
RUN echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

# Volume and Command
VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/lib/systemd/systemd"]
