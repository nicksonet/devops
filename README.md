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



