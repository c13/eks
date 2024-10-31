### Requirements

* You need access to an AWS account with IAM permissions to create an EKS cluster, and an AWS Cloud9 environment if you're running the commands listed in this tutorial.
* Install and configure the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* Install the [Kubernetes CLI (kubectl)](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
* Install the [Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* (Optional*) Install Helm ([the package manager for Kubernetes](https://helm.sh/docs/intro/install/))

### Preparing to create cluster

Before running terraform you can change all domains to yours by running Replace in files command. Replace zetarin.org to your domain name.

You could apply terraform from main folder to create Cloudwatch log group for EKS and Cloudtrail logs and bucket for AWS api logs.

#### Create an EKS Cluster using Terraform

The Terraform template included in this repository is going to create a VPC, an EKS control plane, and a Kubernetes service account along with the IAM role and associate them using IAM Roles for Service Accounts (IRSA) to let Karpenter launch instances. 
Additionally, the template configures the Karpenter node role to the `aws-auth` configmap to allow nodes to connect, and creates an On-Demand managed node group for the `kube-system` and `karpenter` namespaces.
Also it creates ecr with public repo cache, install cluster autoscaler, external-dns, prometheus monitoring stack with grafana, nginx ingress and aws load balancer controller

To create the cluster, clone this repository and open the `cluster/terraform` folder.

Then, create file with variables testing.tfvars

```
# generate new token here https://app.docker.com/settings/personal-access-tokens
# pass your username and token in variable
docker_secret    = { username = "username", accessToken = "token" }
# pass hosted zone id from here https://us-east-1.console.aws.amazon.com/route53/v2/hostedzones?region=us-east-1#
dns_zone         = ""
# for testing purpose
capacity_type    = "SPOT"
```

Finally, run the following commands:

```
cd cluster
helm registry logout public.ecr.aws
export TF_VAR_region=$AWS_REGION
terraform init
terraform apply -target="module.vpc" -auto-approve -var-file="testing.tfvars"
terraform apply -target="module.ecr" -auto-approve -var-file="testing.tfvars"
terraform apply -target="module.eks" -auto-approve -var-file="testing.tfvars"
terraform apply --auto-approve -var-file="testing.tfvars"
```

Before you continue, you need to enable your AWS account to launch Spot instances if you haven't launch any yet. To do so, create the [service-linked role for Spot](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-requests.html#service-linked-roles-spot-instance-requests) by running the following command:

```
aws iam create-service-linked-role --aws-service-name spot.amazonaws.com || true
```

You might see the following error if the role has already been successfully created. You don't need to worry about this error, you simply had to run the above command to make sure you have the service-linked role to launch Spot instances:

```
An error occurred (InvalidInput) when calling the CreateServiceLinkedRole operation: Service role name AWSServiceRoleForEC2Spot has been taken in this account, please try a different suffix.
```

Once complete (after waiting about 15 minutes), run the following command to update the `kube.config` file to interact with the cluster through `kubectl`:

```
aws eks --region $AWS_REGION update-kubeconfig --name karpenter
```

You need to make sure you can interact with the cluster and that the Karpenter pods are running:

```
$> kubectl get pods -n karpenter
NAME                       READY STATUS  RESTARTS AGE
karpenter-5f97c944df-bm85s 1/1   Running 0        15m
karpenter-5f97c944df-xr9jf 1/1   Running 0        15m
```

You might need to review Karpenter logs, so let's create an alias for that to read logs by simply running `kl`:

```
alias kl="kubectl -n karpenter logs -l app.kubernetes.io/name=karpenter --all-containers=true -f --tail=20"
```

## Distruption budget

Karpenter's actions like consolidation, drift detection and `expireAfter`, allow users to optimize for cost in the case of consolidation, keep up with the latest security patches and desired configuration, or ensure governance best practices, like refreshing instances every N days. These actions cause, as a trade-off, some level of disruption in the cluster caused by expected causes. To control the trade-off between, for example, being on the latest AMI (drift detection) and nodes restarting when that happens we can use disruption controls and configure `disruption budgets` in the Karpenter `NodePool` configuration. If no disruption budget is configured their is a default budget with `nodes: 10%`. When calculating if a budget will block nodes from disruption, Karpenter checks if the number of nodes being deleted is greater than the number of allowed disruptions. Budgets take into consideration voluntary disruptions through expiration, drift, emptiness and consolidation. If there are multiple budgets defined in the `NodePool`, Karpenter will honour the most restrictive of the budgets.

By applying a combination of disruptions budgets and Pod Disruptions Budgets (PDBs) we can get both application and platform voluntary disruption controls, this can help you move towards continually operations to protect workload availability.

### Limit Disruptions to a Percentage of Nodes

To prevent disruptions from affecting more than a certain percentage of nodes in a NodePool

I have configured to allow only 1 disruption per 20 minutes during peak hours.

This configuration ensures that Karpenter avoids disrupting workloads during peak traffic periods. Specifically, it prevents disruptions from UTC 9:00 for an 8-hour window and limits disruptions to 20% outside of this window.

```
    budgets:
    - nodes: "1"
      schedule: "0 9 * * *"
      duration: 8h
    - nodes: "20%"
      schedule: "0 17 * * *"
      duration: 16h
```

Please, read deploy/README.md to deploy workload after cluster successfully created.