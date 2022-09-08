# ansible-chainlink

Create HA Kubernetes at VPS

If there is any obstacle you can always check the [official documentation](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/)

On the hosts.yaml change the hosts to yours. We are following the schema above but the wireguard servers can be on others servers.

After running 1vpn.yaml ansible playbooks try to connect to servers each other using 192.168.0.n ipv4.

After running 2lb:

- Try HaProxy at load balancer servers:

```
  netstat -ntlp
  tcp 0 0 192.168.0.1:6443 0.0.0.0:\* LISTEN 2833/haproxy
```

- Check ip at firt server:

```
  ip a
  192.168.0.1/32
```

- Check connection from other servers (master):

```
  nc -v 192.168.0.1 6443
  Connection to 192.168.0.1 6443 port [tcp/*] succeeded!
```

If doesnt work, restart keepalived service at master lb manually

After running step 4b_etcd_credentials, check if really etcd nodes are well configurated.

- First get the kubernetes version:
  kubectl version --short

- Then check the etcd version that kubernetes is using:
  kubeadm config images list --kubernetes-version ${K8S_VERSION}

Finally check the etcd clusters are healthy being root:

```
docker run --rm -it \
--net host \
-v /etc/kubernetes:/etc/kubernetes k8s.gcr.io/etcd:${ETCD_TAG} etcdctl \
--cert /etc/kubernetes/pki/etcd/peer.crt \
--key /etc/kubernetes/pki/etcd/peer.key \
--cacert /etc/kubernetes/pki/etcd/ca.crt \
--endpoints https://192.168.0.2:2379 endpoint health --cluster
member 37245675bd09ddf3 is healthy: got healthy result from https://192.168.0.3:2379
member 532d748291f0be51 is healthy: got healthy result from https://192.168.0.4:2379
member 59c53f494c20e8eb is healthy: got healthy result from https://192.168.0.2:2379
cluster is
```

Run 5master playbook. Connect with the master node via ssh and as root run the following:

```
kubeadm init --config kubeadm-config.yaml --upload-certs --v=9
```

Write the output join commands that are returned to a text file for later use

Run the following on the desired host:

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Install helm:

```
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

Configure network

As first option you can use Cilium:

```
helm repo add cilium https://helm.cilium.io/

kubectl create secret generic -n kube-system cilium-etcd-secrets \
    --from-file=etcd-client-ca.crt=/etc/kubernetes/pki/etcd/ca.crt \
    --from-file=etcd-client.key=/etc/kubernetes/pki/apiserver-etcd-client.key \
    --from-file=etcd-client.crt=/etc/kubernetes/pki/apiserver-etcd-client.crt

helm install cilium cilium/cilium --version 1.12.1 \
  --namespace kube-system \
  --set etcd.enabled=true \
  --set etcd.ssl=true \
  --set "etcd.endpoints[0]=https://192.168.0.2:2379" \
  --set "etcd.endpoints[1]=https://192.168.0.3:2379" \
  --set "etcd.endpoints[2]=https://192.168.0.4:2379"
```

Another option is to use Veave:

```
kubectl --kubeconfig /etc/kubernetes/admin.conf apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
kubectl --kubeconfig /etc/kubernetes/admin.conf get pod -n kube-system -w
```

Finally, connect workers and masters nodes with the commands stored before.
