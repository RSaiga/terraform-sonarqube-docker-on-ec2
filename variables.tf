variable "docker_compose" {
  type = string
  default =  <<EOF
version: "3"

services:
  sonarqube:
    container_name: sonarqube
    image: sonarqube:latest
    restart: always
    ports:
      - "80:9000"
    environment:
      - sonar.jdbc.url=jdbc:postgresql://sonarqube-db:5432/sonar
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
EOF
}