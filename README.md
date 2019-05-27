# Info 

```
https://medium.com/@sachin.arote1/kubernetes-best-practices-9b1435a4cb53
```

```
https://hackernoon.com/the-best-architecture-with-docker-and-kubernetes-myth-or-reality-77b4f8f3804d
```


### Security 


* [Check security Kernel param](https://github.com/a13xp0p0v/kconfig-hardened-check)


```
kubectl get secrets --all-namespaces | grep token
kubectl get secrets default-token-zfkwc -n gitlab -o yaml
```

copy cast ca.key

for token get the secret and base64 decode it

```
echo $TOKEN | base 64 -d 
```

use base 64 -D for MAC shell 

```
hot to configure gitlab for kuberntenetes
https://edenmal.moe/post/2017/GitLab-Kubernetes-Perfect-Match-for-Continuous-Delivery-with-Container/#step-6-add-docker-login-information-to-kubernetes
```

#### Use configmap

Add config map to kubernetes
```
kubectl create configmap test --from-file=config.json=config.json -n stage
```



CHEETSSHIT



## Useful Commands

Get kubectl version

    kubectl version

Get cluster info:

    kubectl cluster-info


## Viewing, Finding Resources


### Columnar output

    kubectl get services                          # List all services in the namespace
    kubectl get pods --all-namespaces             # List all pods in all namespaces
    kubectl get pods -o wide                      # List all pods in the namespace, with more details
    kubectl get rc <rc-name>                      # List a particular replication controller
    kubectl get pods -l env=production            # List all pods with a label env=production

### Verbose output

    kubectl describe nodes <node-name>
    kubectl describe pods <pod-name>
    kubectl describe pods <rc-name>               # Lists pods created by <rc-name> using common prefix

### List Services Sorted by Name

    kubectl get services --sort-by=.metadata.name

### List pods Sorted by Restart Count

    kubectl get pods --sort-by=.status.containerStatuses[0].restartCount

### Get the version label of all pods with label app=cassandra

    kubectl get pods --selector=app=cassandra rc -o 'jsonpath={.items[*].metadata.labels.version}'

### Get ExternalIPs of all nodes

    kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=ExternalIP)].address}'


### Check which nodes are ready
    kubectl get nodes -o jsonpath='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'| tr ';' "\n"  | grep "Ready=True"


## Creating Objects

    kubectl create -f ./file.yml
    kubectl create -f ./file1.yml -f ./file2.yaml
    kubectl create -f ./dir
    kubectl create -f http://www.fpaste.org/279276/48569091/raw/

### Create multiple YAML objects from stdin
    cat <<EOF | kubectl create -f -
    apiVersion: v1
    kind: Pod
    metadata:
      name: busybox-sleep
    spec:
      containers:
      - name: busybox
        image: busybox
        args:
        - sleep
        - "1000000"
    ---
    apiVersion: v1
    kind: Pod
    metadata:
      name: busybox-sleep-less
    spec:
      containers:
      - name: busybox
        image: busybox
        args:
        - sleep
        - "1000"
    EOF

# Create a secret with several keys
    cat <<EOF | kubectl create -f -
    apiVersion: v1
    kind: Secret
    metadata:
      name: mysecret
    type: Opaque
    data:
      password: $(echo -n "Sup3rS3cr3t" | base64)
      username: $(echo -n "superuser" | base64)
    EOF


## Modifying and Deleting Resources


    kubectl label pods <pod-name> new-label=awesome                  # Add a Label
    kubectl annotate pods <pod-name> icon-url=http://goo.gl/XXBTWq   # Add an annotation
    kubectl delete pod pingredis-XXXXX

## Scaling up & down

    kubectl scale --replicas=3 deployment nginx


### Interacting with running Pods


    kubectl logs <pod-name>
    kubectl logs -f <pod-name>

    kubectl run -i --tty busybox --image=busybox -- sh      # Run pod as interactive shell
    kubectl attach <podname> -i                             # Attach to Running Container
    kubectl port-forward <podname> <local-and-remote-port>  # Forward port of Pod to your local machine
    kubectl port-forward <servicename> <port>               # Forward port to service
    kubectl exec <pod-name> -- ls /                         # Run command in existing pod (1 container case)
    kubectl exec <pod-name> -c <container-name> -- ls /     # Run command in existing pod (multi-container case)


## Checking that the DNS works:

    kubectl exec busybox -- nslookup kubernetes
    kubectl exec busybox -- nslookup kubernetes.default
    kubectl exec busybox -- nslookup kubernetes.default.svc.cluster.local


## Create an expose a deployment
    kubectl run nginx --image=nginx:1.9.12
    kubectl expose deployment nginx --port=80 --type=LoadBalancer

## Create a ConfigMap from a file

    kubectl create configmap nginx-ghost --from-file=configs/ghost.conf --namespace=ghost

## Create a secret from a file

    kubectl create secret generic db-user-pass --from-file=./username.txt --from-file=./password.txt

## Handy bash Aliases

    alias k="kubectl"
    alias kc="kubectl create -f"
    alias kg="kubectl get"
    alias pods="kubectl get pods"
    alias allpods="kubectl get pods --all-namespaces"
    alias rcs="kubectl get rc"
    alias svcs="kubectl get services"
    alias dep="kubectl get deployment"
    alias kd="kubectl describe"
    alias kdp="kubectl describe pod "
    alias kds="kubectl describe service "
    alias nodes="kubectl get nodes"
    alias klogs="kubectl logs"
    alias ns="kubectl get ns"
    alias deploys="kubectl get deployment"
    alias events="kubectl get events"
    alias kexec="kubectl exec -it "
    alias secrets="kubectl get secrets"
    alias igs="kubectl get ingress"
    alias contexts="kubectl config get-contexts"
    alias ktop="kubectl top nodes"

## Handy bash functions


### Delete pod, don't wait

    function dp(){
      kubectl delete pod $1 --grace-period=0
    }

### Secrets related functions

    function encode(){
      echo -n "$1" | base64
    }


    function decode(){
      echo -n "$1" | base64 -D
    }

    function gettoken(){
      kubectl get secret $(kubectl get secret | grep default | awk '{print $1}') -o yaml | grep "token:" | awk '{print $2}' | base64 -D
    }


### set context quickly

    function context(){
      kubectl config use-context $1
    }

### run bash in a pod

    function dex(){
      docker exec -it $1 bash
    }

### Lint

https://jsonlint.com

### Volumes

https://blog.sebastian-daschner.com/entries/multiple-kubernetes-volumes-directory
https://vmware.github.io/container-service-extension/nfs_static_pv.html
https://docs.openshift.org/latest/install_config/storage_examples/shared_storage.html
https://github.com/kubernetes-incubator/nfs-provisioner


### Tools for leaning / 

https://sysadmin.pm/termtosvg/


### Validation kubernetes configuration

https://github.com/garethr/kubeval


## Подготовка к интервью на SRE

https://github.com/mxssl/sre-interview-prep-guide
