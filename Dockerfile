FROM phusion/baseimage:bionic-1.0.0
MAINTAINER kzorba@nixly.net

# Install some tools
RUN install_clean bash-completion iproute2 iputils-ping telnet

# Install gobgp from binary distribution
RUN curl -L https://github.com/osrg/gobgp/releases/download/v2.27.0/gobgp_2.27.0_linux_amd64.tar.gz -o /root/gobgp_2.27.0_linux_amd64.tar.gz
RUN tar xvfz /root/gobgp_2.27.0_linux_amd64.tar.gz gobgpd && mv gobgpd /usr/local/sbin && chown 755 /usr/local/sbin/gobgpd
RUN tar xvfz /root/gobgp_2.27.0_linux_amd64.tar.gz gobgp && mv gobgp /usr/local/bin && chown 755 /usr/local/bin/gobgp
RUN rm /root/gobgp_2.27.0_linux_amd64.tar.gz
RUN mkdir /etc/gobgpd

# gobgp client bash completion
RUN curl https://raw.githubusercontent.com/osrg/gobgp/v2.27.0/tools/completion/gobgp-completion.bash -o /root/gobgp-completion.bash
RUN curl https://raw.githubusercontent.com/osrg/gobgp/v2.27.0/tools/completion/gobgp-static-completion.bash -o /root/gobgp-static-completion.bash
RUN curl https://raw.githubusercontent.com/osrg/gobgp/v2.27.0/tools/completion/gobgp-dynamic-completion.bash -o /root/gobgp-dynamic-completion.bash
RUN echo "source /etc/bash_completion" >> /root/.bashrc
RUN echo "source /root/gobgp-completion.bash" >> /root/.bashrc

# script to load prefixes in gobgp rib
COPY scripts/goBGPFeed.sh /usr/local/bin
RUN chmod 755 /usr/local/bin/goBGPFeed.sh

# script to generate gobgpd config upon container startup
COPY scripts/gen_goBGPConf.py /usr/local/bin
RUN chmod u+x /usr/local/bin/gen_goBGPConf.py
COPY scripts/99_gen_gobgp_conf.sh /etc/my_init.d/
RUN chmod u+x /etc/my_init.d/99_gen_gobgp_conf.sh 

# gobgpd runit service 
RUN mkdir /etc/service/gobgpd
COPY scripts/run-gobgpd.sh /etc/service/gobgpd/run
RUN chmod u+x /etc/service/gobgpd/run

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
