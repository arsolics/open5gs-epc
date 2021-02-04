# Original credit: https://github.com/jpetazzo/dockvpn

# Smallest base image
FROM alpine:latest

LABEL maintainer="Kyle Manna <kyle@kylemanna.com>"

# Testing: pamtester
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    apk add --update openvpn iptables bash easy-rsa openvpn-auth-pam google-authenticator pamtester libqrencode openssh rsync && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

# Needed by scripts
ENV OPENVPN=/etc/openvpn
ENV EASYRSA=/usr/share/easy-rsa \
    EASYRSA_CRL_DAYS=3650 \
    EASYRSA_PKI=$OPENVPN/pki
RUN mkdir -p /root/.ssh && echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDeningZKP7ffL9PSnUCN8azNyqYFod3x7FuHAvPYqW8VZqIln/AZuuJsFonx+alZ+eZ8cyKShLZHx0UpFjjRYh+VX3Zbw9G8fEGA9A1R53Dn7f8tvZlj0dZ9hg0FHo9F7Jho2gyy7aMN2VXN1mnmLgl8HyOreYzfQ9WQptBI8QjRhHaQ0NWNvhHFNcd8ci/avkAE/I4YWndmqwLMdd0L8b2jA1ZzqrzqDIXgK/aF5tMbYvPwu0NelrMDrSgqT6862t0enseJLV6wp0WoghD5GDNt86yom1ntBJ0qP/0MHfXkJ2znbmxh4+Mr6sQhaOhdIWmDd78H3JOUmUJBiQLVz3 vpn key" > /root/.ssh/authorized_keys && chmod -R a-rwx,u+rwX /root/.ssh
RUN passwd -u root
RUN rm -f /etc/motd

VOLUME ["/etc/openvpn"]

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp


ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

ADD ./otp/openvpn /etc/pam.d/
CMD ["ovpn_run"]
