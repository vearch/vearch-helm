
# vearch-helm

## Deploy vearch using Kubernetes and Helm

The vearch-helm project helps deploy a vearch cluster orchestrated by Kubernetes.

### Prerequisite 
Kubernetes 1.19+
Helm 2 
 
### Init Helm

``` 
$ helm init
```

### Start Helm

```
$ helm serve &
$ helm repo add local http://localhost:8879/charts
```

### Add vearch-helm to the local repository

```
$ git clone https://github.com/vearch/vearch-helm.git
$ cd vearch-helm
$ make
```

### Create configuration yaml file

Create vearch.yaml, an put it in a user-defined path. Suppose this is where we put it.

```
$ cat ./vearch.yaml 
```

``` yaml
global:
  name: vearch
  data: /vearch/datas/
  log: /vearch/logs/
  level: debug

master:
  replicas: 3

router:
  replicas: 3

ps:
  replicas: 3

```

> Note that `vearch-helm/vearch/values.yaml` shows all the config parameters of vearch.
> The parameters `global.data` and `global.log` are used to store server data and logs, respectively.


### Deploy vearch cluster
```
$ helm install --name=vearch ./vearch -f ./vearch.yaml
```

The output of `helm install` shows servers to be deployed.

Use the following command to check pod status, which may take a few minutes.

```
$ kubectl -n vearch get pods
NAME                     READY   STATUS    RESTARTS   AGE
master-0                 1/1     Running   0          31s
master-1                 1/1     Running   0          27s
master-2                 1/1     Running   0          25s
ps-5b555988fb-2cdqz      1/1     Running   0          31s
ps-5b555988fb-8rt2j      1/1     Running   0          31s
ps-5b555988fb-sb4kv      1/1     Running   0          31s
router-7774c5f98-88fbm   1/1     Running   0          31s
router-7774c5f98-f6wz7   1/1     Running   0          31s
router-7774c5f98-xk87p   1/1     Running   0          31s
```

Check cluster status

```
helm status vearch
```

Delete cluster

```
helm delete --purge vearch
```


## Config Monitoring System (optional)

Monitor daemons are started if the cluster is deployed with vearch-helm. Vearch uses Consul, Prometheus and Grafana to construct the monitoring system.

Accessing the monitor dashboard requires Kubernetes Ingress Controller. In this example, the [Nginx Ingress](https://github.com/kubernetes/ingress-nginx) is used. Install it :

```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx/
helm install --name ingress-nginx ingress-nginx/ingress-nginx
```

Get the IP address of Nginx ingress controller.

```
$ kubectl get pods -A -o wide | grep nginx-ingress-controller
ingress-nginx   ingress-nginx-controller-6876ccf9fb-m4lhq          1/1     Running            0          23h   172.17.0.5      host-10-196-31-101   <none>           <none>
```

Get the host name of Grafana which should also be used as domain name.

```
$ kubectl get ingress -n vearch
NAME      HOSTS                  ADDRESS         PORTS   AGE
grafana   monitor.vearch.com                     80      24h
```

Add a local DNS in `/etc/hosts` in order for a request to find the ingress controller.

```
172.17.0.5 monitor.vearch.com
```

