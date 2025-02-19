# Cluster Monitoring

Video Setup:

https://www.youtube.com/watch?v=8tgdxKizBsE

## Importance of Cluster Monitoring on Linux Machines
Cluster monitoring is crucial for managing Linux machines. Effective monitoring helps detect and resolve issues promptly, provides insights into resource usage (CPU, memory, disk, network), aids in capacity planning, and ensures infrastructure scales with workload demands. By monitoring system performance and health, administrators can prevent downtime, reduce costs, and improve efficiency.

![image](https://github.com/ChpcTraining/monitoring_vms/assets/157092105/f951e4b7-20ff-49a4-b9a7-28aa57e51f5b)

## Traditional Approach Using top or htop
Traditionally, Linux system monitoring involves command-line tools like top or htop. These tools offer real-time system performance insights, displaying active processes, resource usage, and system load. While invaluable for monitoring individual machines, they lack the ability to aggregate and visualize data across multiple nodes in a cluster, which is essential for comprehensive monitoring in larger environments.

![image](https://github.com/ChpcTraining/monitoring_vms/assets/157092105/7e0c8b92-adc2-4106-94ee-ca4ee78a13f5)

## Using Grafana, Prometheus, and Node Exporter
Modern solutions use Grafana, Prometheus, and Node Exporter for robust and scalable monitoring. Prometheus collects and stores metrics, Node Exporter provides system-level metrics, and Grafana visualizes this data. This combination enables comprehensive cluster monitoring with historical data analysis, alerting capabilities, and customizable visualizations, facilitating better decision-making and faster issue resolution.

![image](https://github.com/ChpcTraining/monitoring_vms/assets/157092105/3f64a8bd-87fa-4b51-9576-b28da3af632b)


## What is Docker and Docker Compose and How We Will Use It
Docker is a platform for creating, deploying, and managing containerized applications. Docker Compose defines and manages multi-container applications using a YAML file. For cluster monitoring on a Rocky Linux head node, we will use Docker and Docker Compose to bundle Grafana, Prometheus, and Node Exporter into deployable containers. This approach simplifies installation and configuration, ensuring all components are up and running quickly and consistently, streamlining the deployment of the monitoring stack.

# How to use the notes

When the word **Input:** is mentioned, excpect the next line to have commands that you need to copy and paste into your own terminal.

When the word **Output:** is mentioned **DON'T** copy and paste anything below this word as this is just the expected output.

# Pre-requisites

## Ubuntu Setup

```
nano install_docker.sh
```

```
#!/bin/bash

set -e  # Exit on error

# Update package lists
echo "Updating system..."
sudo apt update -y

# Install required packages
echo "Installing dependencies..."
sudo apt install -y ca-certificates curl gnupg

# Add Docker’s official GPG key
echo "Adding Docker’s GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo "Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y

# Install Docker Engine and dependencies
echo "Installing Docker..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker
echo "Starting and enabling Docker..."
sudo systemctl start docker
sudo systemctl enable docker

# Verify installation
echo "Docker Version:"
sudo docker --version

echo "Docker Compose Version:"
sudo docker compose version

echo "Docker installation complete!"

```

```
chmod +x install_docker.sh
```

```
./install_docker.sh
```

## Rocky Setup

1. Rocky 9.03 VM and ssh keys working
2. Have nano installed, if not installed use this:

Input:
```
sudo yum install nano -y
```

3. Install Docker Engine and Docker Compose:
based on following: [https://docs.docker.com/engine/install/rhel/#install-using-the-repository](https://docs.docker.com/engine/install/rhel/#install-using-the-repository)

Install steps:

- Install the yum-utils package (which provides the yum-config-manager utility) and set up the repository.

Input:
```
sudo yum install -y yum-utils
```

Input:
```
sudo yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
```

- Install Docker Engine, containerd, and Docker Compose:

Input:
```
sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

If prompted to accept the GPG key, verify that the fingerprint matches, accept it.

This command installs Docker, but it doesn't start Docker. It also creates a docker group, however, it doesn't add any users to the group by default.

- Start Docker:

Input:
```
sudo systemctl start docker
```

- Verify that the Docker Engine installation is successful by running the hello-world image:

Input:
```
sudo docker run hello-world
```

This command downloads a test image and runs it in a container. When the container runs, it prints a confirmation message and exits.

You have now successfully installed and started Docker Engine.

- Confirm you have docker compose:

Input:
```
docker compose version
```

Output:
```
$ docker compose version
Docker Compose version v2.28.1
```

# Installing Monitoring Stack
- Pre-requisites: each host involved needs to have docker-ce and docker-compose installed as mentioned in the previous section
- Create a suitable directory, e.g. /opt/monitoring_stack, in which you’ll keep a
number of important configuration files.

Input:
```
sudo mkdir /opt/monitoring_stack/
cd /opt/monitoring_stack/
```

- In /opt/monitoring_stack/, create a docker-compose.yml file containing the
following lines:

Input:
```
sudo nano /opt/monitoring_stack/docker-compose.yml
```

Input into file:
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

> If you want to make grafana publically available then change ports to `80:3000`

- We then need to create two additional files, firstly:

Input:
```
sudo nano /opt/monitoring_stack/prometheus.yml
```

Input into file:
```
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
```

- secondly:

Input:
```
sudo nano /opt/monitoring_stack/prometheus-datasource.yaml
```

Input into file:
```
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
```

# Start the services

Input:
```
sudo docker compose up -d
```

You should then see:

Output:
```
$ sudo docker compose up -d
[+] Running 4/4
✔ Network monitoring_stack_monitoring-network Created 0.3s
✔ Container monitoring_stack-grafana-1 Started 0.2s
✔ Container monitoring_stack-prometheus-1 Started 0.3s
✔ Container monitoring_stack-node-exporter-1 Started 0.2s
```

Then do 

Input:
```
sudo docker ps
```

Output:
```
/opt/monitoring_stack$ sudo docker ps
CONTAINER ID   IMAGE                COMMAND                  CREATED      STATUS        PORTS                                       NAMES
2b707570dc41   grafana/grafana      "/run.sh"                6 days ago   Up 12 hours   0.0.0.0:3000->3000/tcp, :::3000->3000/tcp   monitoring_stack-grafana-1
ea730ef94381   prom/prometheus      "/bin/prometheus --c…"   6 days ago   Up 10 hours   0.0.0.0:9090->9090/tcp, :::9090->9090/tcp   monitoring_stack-prometheus-1
704dfa94ecf3   prom/node-exporter   "/bin/node_exporter"     6 days ago   Up 12 hours   0.0.0.0:9100->9100/tcp, :::9100->9100/tcp   monitoring_stack-node-exporter-1
```

Now let us verify the services!

# Prometheus

Input:
```
curl -s localhost:9090/metrics | head
```

You should see:

Output:
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

# Node Exporter

Input:
```
curl -s localhost:9100/metrics | head
```

You should see:

Output:
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

# Grafana

Input:
```
curl -s localhost:3000 | head
```

You should see:

Output:
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

Now you can also go to a local browser. 

Open a new terminal and run the tunnel command (replace xxx.xxx.xxx.xxx with your unique IP):

Input:
```
$ ssh -L 3000:localhost:3000 rocky@xxx.xxx.xxx.xxx
```

You should see something like this (note you will have a different IP address):

Output:
```
$ ssh -L 3000:localhost:3000 rocky@154.114.57.102
Last login: Wed Jul  3 12:05:29 2024 from 41.10.78.210
[rocky@demo-bb ~]$
```

Then open up a browser

```
http://localhost:3000
```

![image](https://github.com/ChpcTraining/monitoring_vms/assets/157092105/abee2bcd-3f6c-437b-aee7-edfa31550d42)


# Create a Dashboard in Grafana

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

Click on New then Import

![image](https://github.com/ChpcTraining/monitoring_vms/assets/157092105/4efa0d71-7278-454d-a815-8b6f1f1c72a3)

Input: 1860 and click Load 

![image](https://github.com/ChpcTraining/monitoring_vms/assets/157092105/d8cda594-0468-4ec0-876a-7beeaf79589f)

Click on source: "Prometheus"

![image](https://github.com/ChpcTraining/monitoring_vms/assets/157092105/257351d2-f078-4140-9a37-0b8a4b1b59b8)

Click on Import:

![image](https://github.com/ChpcTraining/monitoring_vms/assets/157092105/f078be7e-2663-4947-b8fd-fc6c6d548513)

Then you should see:

![image](https://github.com/ChpcTraining/monitoring_vms/assets/157092105/0568acc5-5248-4b90-8803-5f58d2af11e2)

# Adding Persistant Storage as Volume and Config File

Copy default grafana.ini file to working directory, this to allow for any user.

Create folders and set permissions

```
sudo mkdir -p /opt/monitoring_stack/grafana-data
sudo mkdir -p /opt/monitoring_stack/prometheus-data
sudo chown -R 472:472 /opt/monitoring_stack/grafana-data  # Grafana runs as UID 472
sudo chown -R 65534:65534 /opt/monitoring_stack/prometheus-data  # Prometheus runs as nobody:nogroup
```

Then update `docker-compose.yml`

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
      - /opt/monitoring_stack/prometheus-data:/prometheus  # Persist Prometheus data
    networks:
      - monitoring-network

  grafana:
    image: grafana/grafana
    ports:
      - "80:3000"
    restart: always
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin
    volumes:
      - /opt/monitoring_stack/prometheus-datasource.yaml:/etc/grafana/provisioning/datasources/prometheus-datasource.yaml
      - /opt/monitoring_stack/grafana.ini:/etc/grafana/grafana.ini
      - /opt/monitoring_stack/grafana-data:/var/lib/grafana  # Persist Grafana data
    networks:
      - monitoring-network

networks:
  monitoring-network:
    driver: bridge
```

Then down and up docker...
