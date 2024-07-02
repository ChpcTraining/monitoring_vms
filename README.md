# monitoring_vms

# Pre-requisites

1. Ubuntu 22.04 VM or similar
2. Install Docker Enginer: using apt repo: https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
- tip: input commands line-by-line not all at once
- tip: do https://docs.docker.com/engine/install/linux-postinstall/
3. Install Docker Compose: https://docs.docker.com/compose/install/linux/#install-using-the-repository

# Installation via docker-compose
- Pre-requisites: each host involved needs to have docker-ce and docker-compose installed as mentioned in the previous section
- Create a suitable directory, e.g. /opt/monitoring_stack, in which you’ll keep a
number of important configuration files.

```css
mkdir /opt/monitoring_stack/
cd /opt/monitoring_stack/
```

```sql
mkdir /opt/monitoring_stack/
cd /opt/monitoring_stack/
```

```yml
mkdir /opt/monitoring_stack/
cd /opt/monitoring_stack/
```

- In /opt/monitoring_stack/, create a docker-compose.yml file containing the
following lines:

`/opt/monitoring_stack/docker-compose.yml`:

```
version: '3'
services:
  node-exporter:
    image: prom/node-exporter
    ports:
      - "9100:9100"
    restart: always
    networks:
      - monitoring-network

  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    restart: always
    volumes:
      - /opt/monitoring_stack/prometheus.yml:/etc/prometheus/prometheus.yml
    networks:
      - monitoring-network

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    restart: always
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin
    volumes:
      - /opt/monitoring_stack/prometheus-datasource.yaml:/etc/grafana/provisioning/datasources/prometheus-datasource.yaml
    networks:
      - monitoring-network

networks:
  monitoring-network:
    driver: bridge
```

- We then need to create two additional files, firstly:

`/opt/monitoring_stack/prometheus.yml`:

```
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
```

- secondly:

`/opt/monitoring_stack/prometheus-datasource.yaml`:

```
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
```

# Start the services

Use:

```
docker compose up -d
```

You should then see:

```
$ docker compose up -d
[+] Running 4/4
✔ Network monitoring_stack_monitoring-network Created 0.3s
✔ Container monitoring_stack-grafana-1 Started 0.2s
✔ Container monitoring_stack-prometheus-1 Started 0.3s
✔ Container monitoring_stack-node-exporter-1 Started 0.2s
```

Now let us verify the services!

# Prometheus

Input:

```
curl -s localhost:9090/metrics | head
```

You should see:

```
$ curl -s localhost:9090/metrics | head
# HELP go_gc_cycles_automatic_gc_cycles_total Count of completed GC cycles generated by the Go runtime.
# TYPE go_gc_cycles_automatic_gc_cycles_total counter
go_gc_cycles_automatic_gc_cycles_total 5
# HELP go_gc_cycles_forced_gc_cycles_total Count of completed GC cycles forced by the application.
# TYPE go_gc_cycles_forced_gc_cycles_total counter
go_gc_cycles_forced_gc_cycles_total 0
# HELP go_gc_cycles_total_gc_cycles_total Count of all completed GC cycles.
# TYPE go_gc_cycles_total_gc_cycles_total counter
go_gc_cycles_total_gc_cycles_total 5
# HELP go_gc_duration_seconds A summary of the pause duration of garbage collection cycles.
# TYPE go_gc_duration_seconds summary
go_gc_duration_seconds{quantile="0"} 7.81e-05
go_gc_duration_seconds{quantile="0.25"} 0.000135
...
```

You can also go to a browser and input: http://localhost:9090

You should see:

![image](https://github.com/ChpcTraining/monitoring_vms/assets/157092105/02626e71-89e0-4647-99d1-9362e68c97c9)

## Debugging

What happens if you don't see the expected output?
- check if the services are running

# Node Exporter

Input:

```
curl -s localhost:9100/metrics | hea
```

You should see:

```
$ curl -s localhost:9100/metrics | head
# HELP go_gc_duration_seconds A summary of the pause duration of
garbage collection cycles.
# TYPE go_gc_duration_seconds summary
go_gc_duration_seconds{quantile="0"} 2.1937e-05
go_gc_duration_seconds{quantile="0.25"} 3.2322e-05
go_gc_duration_seconds{quantile="0.5"} 3.4946e-05
go_gc_duration_seconds{quantile="0.75"} 5.7424e-05
go_gc_duration_seconds{quantile="1"} 0.000171199
go_gc_duration_seconds_sum 0.007451006
go_gc_duration_seconds_count 157
# HELP go_goroutines Number of goroutines that currently exist
```

Now you can also go to a browser and input: http://localhost:9100/

You should see:

![image](https://github.com/ChpcTraining/monitoring_vms/assets/157092105/ecce0302-87b3-4420-9588-34a7bc8334d7)

If you click on metrics you should see the same output you got on the terminal:

![image](https://github.com/ChpcTraining/monitoring_vms/assets/157092105/252facbd-162e-4b05-bbd2-3db99228c02f)

## Debugging

What happens if you don't see the expected output?
- check if the services are running

# Grafana

Input the following:

```
curl -s localhost:3000 | head
```

You should see:

```
$ curl -s localhost:3000 | hea
<a href=“/login">Found</a>.
$ curl -s -u admin:admin localhost:3000 | head
<!DOCTYPE html>
<html lang="en-US">
<head>
<meta charset="utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
<meta name="viewport" content="width=device-width" />
<meta name="theme-color" content="#000" />
<title>Grafana</title>
```

Now you can also go to a local browser and see it:

```
http://localhost:3000
```

![image](https://github.com/ChpcTraining/monitoring_vms/assets/157092105/abee2bcd-3f6c-437b-aee7-edfa31550d42)


## Create a Dashboard in Grafana

Go to a browser and input:

```
http://localhost:3000
```

![image](https://github.com/ChpcTraining/monitoring_vms/assets/157092105/abee2bcd-3f6c-437b-aee7-edfa31550d42)

username: admin
password: admin

![image](https://github.com/ChpcTraining/monitoring_vms/assets/157092105/52010bd5-e9fd-4ee1-9703-352507a1e72d)

Go to Dashboards

![image](https://github.com/ChpcTraining/monitoring_vms/assets/157092105/083f2bc3-247a-40ad-b923-2b2007fe9b70)

Click on New -> Import

![image](https://github.com/ChpcTraining/monitoring_vms/assets/157092105/4efa0d71-7278-454d-a815-8b6f1f1c72a3)

Input: 1893 and click Load !!! fix wrong ip

![image](https://github.com/ChpcTraining/monitoring_vms/assets/157092105/1126e48d-dcc1-42b4-a55c-ec29affdb99e)

Click on source: "Node Exporter"

!!! Pending Image !!!

![image](https://github.com/ChpcTraining/monitoring_vms/assets/157092105/193dbb90-7acd-4aba-80cb-7291bcc24f95)

## Alerts
