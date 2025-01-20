FROM atende/baseimage-jdk:jdk8

LABEL maintainer="Giovanni Silva <giovanni@atende.info>"

ENV SOFTWARE_NAME=crowd
ENV SOFTWARE_VERSION=2.8.0
ENV SOFTWARE_PORT=8095

# Disable SSH (Not using it at the moment).
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

COPY install.sh /root/install.sh
RUN chmod +x /root/install.sh

# Install
RUN mkdir /root/scripts
COPY scripts/install_impl.sh /root/scripts/install_impl.sh
RUN chmod +x /root/scripts/install_impl.sh
RUN /root/install.sh

# Run
COPY run.sh /etc/my_init.d/run.sh
COPY scripts/run_impl.sh /root/scripts/run_impl.sh
RUN chmod +x /etc/my_init.d/run.sh

ENV ZULU_VERSION=8.82.0.21
ENV ZULU_BUILD=8.0.432
ENV JAVA_HOME=/usr/lib/jvm/zulu-8

# Remove old JDK
RUN rm -rf /opt/jdk1.8.0_77

# Download and install Zulu JDK
RUN mkdir -p /usr/lib/jvm && \
    curl -fsSL https://cdn.azul.com/zulu/bin/zulu${ZULU_VERSION}-ca-jdk${ZULU_BUILD}-linux_x64.tar.gz | \
    tar -xz -C /usr/lib/jvm && \
    ln -s /usr/lib/jvm/zulu${ZULU_VERSION}-ca-jdk${ZULU_BUILD}-linux_x64 /usr/lib/jvm/zulu-8

RUN update-alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 1000

COPY patch_2.7.1-4ubuntu2.4_amd64.deb /tmp/patch.deb

RUN dpkg -i /tmp/patch.deb && \
    rm /tmp/patch.deb

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="$JAVA_HOME/bin:$PATH"

# Verify installation
RUN java -version

EXPOSE 8095

CMD ["/sbin/my_init"]
