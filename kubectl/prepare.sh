#!/bin/bash
# Remove taints from controler-plane node
kubectl taint nodes --all node-role.kubernetes.io/control-plane:NoSchedule-