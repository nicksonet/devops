In gitlab-ci.yaml | Settings -> CI / CD -> 
необходимо создать следующие переменные 
- CI_REGISTRY_PASSWORD
- CI_REGISTRY_USER
- KUBE_CONFIG



Create KUBE_CONFIG
```
cat ~/.kube/config | base64 | pbcopy
```

