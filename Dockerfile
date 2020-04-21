FROM sebp/elk:671

# remove default logstash chain
RUN rm -rf /etc/logstash/conf.d/*.conf

# add f5 telemetry logstach chain with GeoIP support
ADD 01-f5-telemetry-input.conf /etc/logstash/conf.d/01-input.conf
ADD 11-f5-telemetry-filter.conf /etc/logstash/conf.d/11-filter.conf
ADD 31-f5-telemetry-output.conf /etc/logstash/conf.d/31-output.conf
