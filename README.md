# F5 BIG-IP TS ELK Container

## Introduction

This is a fork from the ELK all in one docker containers found on

  - https://elk-docker.readthedocs.io
  - https://hub.docker.com/r/sebp/elk
  - https://github.com/spujadas/elk-docker
  
They include a fully containerized **Logstash**, **ElasticSearch** and **Kibana** stack

The docker container and sources after the below described modifications can be found on

 - https://github.com/boeboe/elk-f5-ts
 - https://hub.docker.com/repository/docker/boeboe/elk-f5-ts

The get the proper docker command startup flags, please refer to the original documentation, as nothing has changed here

## Modifications

The default docker images contain a Logstash chain for Beats and Nginx. This forked container removes the default Logstash chain and inject an F5 Telemetry Streaming specific Logstash chain

The default location of the Logstash chain configuration is `/etc/logstash/conf.d`

### Input

We use the HTTP input plugin, documented [here](https://www.elastic.co/guide/en/logstash/current/plugins-inputs-http.html)

```
input {
  http {
    type => "f5.telemetry"
    port => 5044
  }
}
```

### Filter

We enrich the `data.client_ip` field in the original F5 BIG-IP Elasticsearch data with **GeoLocation** data for Kibana dashboarding. More information on the GeoIP filter can be found [here](https://www.elastic.co/guide/en/logstash/current/plugins-filters-geoip.html)

We also remove the extra `headers` added by the http input plugin and make sure the `@timestamp` field matches the `data.event_timestamp` from the original data (this matches the HTTP timstamp of the traffic on the wire going through BIG-IP)

```
filter {
  if [type] == "f5.telemetry" {
    date {
      match => ["[data][event_timestamp]" , "yyyy-MM-dd'T'HH:mm:ss.SSSZ"]
      target => "@timestamp"
    }
    mutate {
      remove_field => [ "headers" ]
    }
    geoip {
      source => "[data][client_ip]"
    }
  }
}
```

### Output

We make sure the upstream configured (by TS) index `bigip` and document type `f5.telemetry` match our expectations

```
output {
  elasticsearch {
    hosts => ["localhost"]
    index => "bigip"
    document_type => "f5.telemetry"
  }
}
```

**Note:** This `index` and `document_type` need to match the below example configuration for the F5 TS Elasticsearch Consumer Configuration

## Background

For more information on how to use Telemetry Streaming in combination with Elasticsearch, please refer to the following documentation

  - https://clouddocs.f5.com/products/extensions/f5-telemetry-streaming/latest
  - https://clouddocs.f5.com/products/extensions/f5-telemetry-streaming/latest/setting-up-consumer.html?highlight=elasticsearch#elasticsearch
  - https://clouddocs.f5.com/products/extensions/f5-telemetry-streaming/latest/schema-reference.html
  - https://github.com/F5Networks/f5-telemetry-streaming

Note that we are not sending traffic directly to Elasticsearch, but use Logstash as intermediate transformer and enricher (GeoIP data in this case)

```json
{
    "class": "Telemetry",
    "ELK_Consumer": {
        "class": "Telemetry_Consumer",
        "type": "ElasticSearch",
        "host": "<the IP address of this container>",
        "index": "bigip",
        "port": 5044,
        "protocol": "http",
        "dataType": "f5.telemetry"
    }
}
```

Please be aware you will also need to create a `Traffic_Log_Profile` and attach this to your Virtual Server for the full end-to-end scenario

 - https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/declarations/profiles.html#using-a-traffic-log-profile-in-a-declaration

## Note

This container is purely used for demo purposes and not meant for production environments at all