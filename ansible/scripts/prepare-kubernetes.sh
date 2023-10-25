#!/bin/bash
# Remove taints from controler-plane node
# kubectl taint nodes --all node-role.kubernetes.io/control-plane:NoSchedule-
# Restart coredns at is not working properly when initialized
kubectl -n kube-system rollout restart deployment coredns