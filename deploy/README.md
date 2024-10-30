# Deploy workload

You could deploy sample workload

```
kubectl apply -f workload-graviton.yaml
kubectl apply -f workload-graviton.yaml
```

Check if new nodes created correctly
```
kubectl get nodeclaims.karpenter.sh

NAME            TYPE         CAPACITY   ZONE         NODE   READY     AGE
default-gtg9n   c6g.xlarge   spot       us-east-1c          Unknown   9s
default-v2cfs   c5d.xlarge   spot       us-east-1c          Unknown   15s

kubectl get node

NAME                           STATUS     ROLES    AGE   VERSION
ip-10-0-103-125.ec2.internal   Ready      <none>   85s   v1.30.4-eks-a737599
ip-10-0-107-6.ec2.internal     Ready      <none>   71m   v1.30.4-eks-a737599
ip-10-0-117-14.ec2.internal    NotReady   <none>   6s    v1.30.4-eks-a737599
ip-10-0-81-52.ec2.internal     Ready      <none>   71m   v1.30.4-eks-a737599
```