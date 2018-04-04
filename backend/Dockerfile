FROM ubuntu:16.04

# Install Python

RUN apt-get update && \
    apt-get install python3 python3-dev python3-pip -y

RUN ln -s /usr/bin/python3 /usr/bin/python

# Install utils

RUN apt-get install -y wget xz-utils git

# back-end

RUN git clone https://github.com/our-dev/dtlib.git && \
    cd dtlib && ./install.sh && rm -rf /dtlib
RUN git clone https://github.com/x-utest/xtest-server-base.git && \
    cd xtest-server-base && ./install.sh && rm -rf /xtest-server-base
# TODO: mv front-end code to host
RUN git clone https://github.com/x-utest/xtest-server.git && \
    cd xtest-server && pip3 install -r requirements.txt

# Set DOCKER ENV
ENV DOCKER 1

# Install Nginx

RUN apt-get install nginx -y
RUN cd /etc/nginx/conf.d/ && ln -s /xtest-server/nginx_config/* .


# Define mountable directories.
VOLUME ["/data/db"]

# Define working directory.
WORKDIR /data

# Define default command.
COPY start_server.sh /data/start_server.sh
CMD ["./start_server.sh"]

EXPOSE 8009 8099
