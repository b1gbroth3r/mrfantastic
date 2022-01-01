#!/bin/bash

apt update && apt install -y wget

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list
apt update && apt install -y logstash openjdk-11-jre elasticsearch kibana vim net-tools curl

systemctl enable elasticsearch.service
systemctl enable kibana.service
systemctl enable logstash.service

mkdir -p /etc/elasticsearch/certs/
mkdir -p /etc/kibana/config/certs/
rm /etc/elasticsearch/elasticsearch.yml
rm /etc/kibana/kibana.yml

wget "https://gist.githubusercontent.com/b1gbroth3r/67111f8e4bc327ba06a49bab68b9a446/raw/2cbac975065d60276ba0890f6d4c79b4b5497f03/elasticsearch.yml" -P /etc/elasticsearch/
wget "https://gist.githubusercontent.com/b1gbroth3r/d31d6df7c47174061043a5f4bc28609f/raw/955e749e45a85177b41d94e1923b3efb4d54df55/kibana.yml" -P /etc/kibana/

/usr/share/elasticsearch/bin/elasticsearch-certutil cert --keep-ca-key --pem --in ~/instance.yml --out ~/certs.zip
unzip certs.zip

cp ~/ca/* /etc/elasticsearch/certs/
cp ~/oracle/* /etc/elasticsearch/certs/
cp ~/ca/* /etc/kibana/config/certs/
cp ~/oracle/* /etc/kibana/config/certs/

service elasticsearch start
service kibana start
service logstash start

/usr/share/elasticsearch/bin/elasticsearch-setup-passwords auto | tee ~/creds.txt
/usr/share/kibana/bin/kibana-encryption-keys generate | tee ~/encryption_keys.txt
