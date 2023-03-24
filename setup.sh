#!/bin/bash
#set -eo pipefail
#DEVICE=${local.block_device_path}
#DEST=${var.persistent_volume_mount_path}
#devpath=$(readlink -f $DEVICE)
#if [[ $(file -s $devpath) != *ext4* && -b $devpath ]]; then
#    mkfs -t ext4 $devpath
#fi
#if ! egrep "^$devpath" /etc/fstab; then
#  echo "$devpath $DEST ext4 defaults,nofail,noatime,nodiratime,barrier=0,data=writeback 0 2" | tee -a /etc/fstab > /dev/null
#fi
#mkdir -p $DEST
#mount $DEST
#chown ec2-user:ec2-user $DEST
#chmod 0755 $DEST

yum update -y
amazon-linux-extras install docker
systemctl start docker.service
usermod -a -G docker ec2-user
chkconfig docker on
yum install -y python3-pip
python3 -m pip install docker-compose

#cat > $DEST/docker-compose.yml <<-TEMPLATE
cat > ./docker-compose.yml <<-TEMPLATE
${var.docker_compose}
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
systemctl start custom_service