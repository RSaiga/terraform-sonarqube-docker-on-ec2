#!/bin/bash
yum update -y
amazon-linux-extras install docker
systemctl start docker.service
usermod -a -G docker ec2-user
chkconfig docker on
yum install -y python3-pip
python3 -m pip install docker-compose

cat > ./docker-compose.yml <<-TEMPLATE
version: "3"

services:
  sonarqube:
    container_name: sonarqube
    image: sonarqube:latest
    restart: always
    ports:
      - "80:9000"
    environment:
      - SONAR_JDBC_URL=jdbc:postgresql://sonarqube-db:5432/sonar
      - SONAR_JDBC_USERNAME=sonar
      - SONAR_JDBC_PASSWORD=sonar
    volumes:
      - sonarqube-conf:/opt/sonarqube/conf
      - sonarqube-data:/opt/sonarqube/data
      - sonarqube-extensions:/opt/sonarqube/extensions
    depends_on:
      - sonarqube-db
    networks:
      - sonarqube

  sonarqube-db:
    container_name: sonarqube-db
    image: postgres:latest
    restart: always
    environment:
      - POSTGRES_USER=sonar
      - POSTGRES_PASSWORD=sonar
      - POSTGRES_DB=sonar
    volumes:
      - postgresql-root:/var/lib/postgresql
      - postgresql-data:/var/lib/postgresql/data
    networks:
      - sonarqube

networks:
  sonarqube:
    driver: bridge

volumes:
  sonarqube-conf:
  sonarqube-data:
  sonarqube-extensions:
  postgresql-root:
  postgresql-data:
TEMPLATE
cat > /etc/systemd/system/custom_service.service <<-TEMPLATE
[Unit]
Description=docker service
After=network.target
[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/docker-compose -f ./docker-compose.yml up
Restart=on-failure
[Install]
WantedBy=multi-user.target
TEMPLATE

sudo sysctl -w vm.max_map_count=262144
systemctl start custom_service