FROM openresty/openresty:alpine

# Install dependencies
RUN apk add --no-cache ca-certificates wget unzip tini

# Download and install Xray
RUN wget --timeout=30 -qO /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip -q /tmp/xray.zip -d /tmp/xray/ && \
    mv /tmp/xray/xray /usr/local/bin/ && \
    mkdir -p /usr/local/share/xray/ && \
    mv /tmp/xray/geoip.dat /usr/local/share/xray/ && \
    mv /tmp/xray/geosite.dat /usr/local/share/xray/ && \
    chmod +x /usr/local/bin/xray && \
    xray --version && \
    rm -rf /tmp/xray /tmp/xray.zip

# Copy configs
COPY config.json /etc/xray.json
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY index.html /usr/local/openresty/nginx/html/index.html

ENV XRAY_LOCATION_ASSET=/usr/local/share/xray/
EXPOSE 8080

# Start both services properly
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["sh", "-c", "xray run -c /etc/xray.json & exec openresty -g 'daemon off;'"]
