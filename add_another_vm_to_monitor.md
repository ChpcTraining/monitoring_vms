# Install Docker then Node Exporter via Docker on VM

```
sudo docker run -d --name=node-exporter   -p 9101:9100   --restart always   prom/node-exporter
```

> Note default is actually 9100:9100

It will install it if not there and run it behind the scenes

Check if its working with `curl`:

```
curl -s localhost:9100/metrics | head
```

![image](https://github.com/user-attachments/assets/c1c58488-7a66-44b5-9208-e78b8fe02a43)


# Create Security Group then Rule

![image](https://github.com/user-attachments/assets/7ae6d77c-927a-420b-af45-cfa229fdce86)

![image](https://github.com/user-attachments/assets/3317466a-00a4-485a-814a-6e119a551fde)

## Add Rule - Ingress

![image](https://github.com/user-attachments/assets/96bea019-5108-44b8-892a-61c7e2aefe5b)

For this specific case port is 9101 (usually 9100)

![image](https://github.com/user-attachments/assets/6c7d16ec-83ba-446c-a565-ea3799b401cc)

## Add Security Group "Node Exporter" to VM

![image](https://github.com/user-attachments/assets/1620fc34-10bf-4e73-8ea1-e9bbf3c4d07a)

![image](https://github.com/user-attachments/assets/643b10cc-abc1-4116-8dc1-bb48d9102ddc)

![image](https://github.com/user-attachments/assets/dfd24f46-f58e-4981-b331-2cdd4b9561a3)

# Setup Host VM

Update Grafana to port 80 in `docker-compose.yml`

```
  grafana:
    image: grafana/grafana
    ports:
      - "80:3000"

```

And update `prometheus.yml` to connect to VM2

```
targets: ['node-exporter:9100', '154.114.57.225:9100']
```

Do Docker down and up.

Then check that you can read data from VM2:

```
curl -s 154.114.57.225:9101/metrics | head
```
