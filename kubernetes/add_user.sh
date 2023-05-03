#!/bin/bash

# Prepare new user for kubernetes access
useradd -s /bin/bash mysuser
passwd mysuser
openssl genrsa -out mysuser.key 2048
touch $HOME/.rnd
openssl req -new -key mysuser.key -out mysuser.csr -subj "/CN=mysuser/O=development"
sudo openssl x509 -req -in mysuser.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out mysuser.crt -days 45
kubectl config set-credentials mysuser --client-certificate=/root/mysuser.crt --client-key=/root/mysuser.key
kubectl config set-context mysuser-context --cluster=kubernetes --namespace=development --user=mysuser