# EKS Add-ons Configuration

This document describes the EKS add-ons configured for the cluster and their usage.

## IAM Roles Module

The IAM roles for EKS add-ons are managed using a reusable Terraform module located at `modules/eks-addon-iam-roles`. This module creates IRSA (IAM Roles for Service Accounts) for common EKS add-ons and can be reused across multiple environments.

**Module Location:** `../../../modules/eks-addon-iam-roles`

**Module Documentation:** See [modules/eks-addon-iam-roles/README.md](../../../modules/eks-addon-iam-roles/README.md) for detailed module documentation.

## Enabled Add-ons

### 1. Amazon EFS CSI Driver

The Amazon EFS CSI Driver enables dynamic provisioning of Amazon Elastic File System (EFS) volumes for Kubernetes pods.

**Features:**
- Dynamic provisioning of EFS volumes
- Support for multiple pods accessing the same volume
- Cross-AZ access with consistent performance
- Automatic mount management

**IAM Role:** `eks-nonprod-dev-efs-csi-driver-role`

**Usage Example:**

```yaml
# StorageClass for EFS
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: efs-sc
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: fs-xxxxxxxxx  # Replace with your EFS ID
  directoryPerms: "700"

---
# PersistentVolumeClaim
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: efs-claim
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: efs-sc
  resources:
    requests:
      storage: 5Gi

---
# Pod using EFS
apiVersion: v1
kind: Pod
metadata:
  name: efs-app
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: persistent-storage
      mountPath: /data
  volumes:
  - name: persistent-storage
    persistentVolumeClaim:
      claimName: efs-claim
```

**Prerequisites:**
1. Create an EFS file system in the same VPC as your EKS cluster
2. Ensure security groups allow NFS traffic (port 2049) between EKS nodes and EFS
3. The EFS file system should be in the same region as the cluster

### 2. External DNS

External DNS automatically creates and manages DNS records for Kubernetes services and ingresses in Route53.

**Features:**
- Automatic DNS record creation for services and ingresses
- Support for multiple DNS providers (configured for Route53)
- Sync policy to keep DNS records up to date
- Support for multiple hosted zones

**IAM Role:** `eks-nonprod-dev-external-dns-role`

**IAM Permissions:**
- `route53:ChangeResourceRecordSets` - Create/update DNS records
- `route53:ListHostedZones` - List available hosted zones
- `route53:ListResourceRecordSets` - List existing DNS records

**Usage Example:**

```yaml
# Service with External DNS annotation
apiVersion: v1
kind: Service
metadata:
  name: my-app
  annotations:
    external-dns.alpha.kubernetes.io/hostname: myapp.example.com
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: my-app

---
# Ingress with External DNS annotation
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    external-dns.alpha.kubernetes.io/hostname: api.example.com
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-service
            port:
              number: 80
```

**Configuration:**
- **Policy:** `sync` - External DNS will create and delete records
- **Sources:** `service`, `ingress` - Monitors services and ingresses
- **Domain Filters:** Configure in terraform.tfvars to restrict to specific domains

**Prerequisites:**
1. Create a Route53 hosted zone for your domain
2. Update the domain filters in the configuration (if needed)
3. Ensure the IAM role has permissions for the hosted zones you want to manage

## Deployment

The add-ons are automatically deployed when you apply the Terraform configuration:

```bash
cd nonprod/eks/dev
terraform init
terraform plan
terraform apply
```

## Verification

After deployment, verify the add-ons are installed:

```bash
# Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name eks-nonprod-dev

# Check add-ons status
aws eks list-addons --cluster-name eks-nonprod-dev --region us-east-1

# Describe specific add-on
aws eks describe-addon --cluster-name eks-nonprod-dev --addon-name aws-efs-csi-driver --region us-east-1
aws eks describe-addon --cluster-name eks-nonprod-dev --addon-name external-dns --region us-east-1

# Check pods in kube-system namespace
kubectl get pods -n kube-system | grep efs
kubectl get pods -n kube-system | grep external-dns
```

## Troubleshooting

### EFS CSI Driver Issues

1. **Pod cannot mount EFS volume:**
   - Check EFS file system ID is correct
   - Verify security groups allow NFS traffic (port 2049)
   - Ensure EFS mount targets exist in all subnets

2. **Permission denied errors:**
   - Verify IAM role has the correct permissions
   - Check the service account annotation is correct

### External DNS Issues

1. **DNS records not being created:**
   - Check External DNS pod logs: `kubectl logs -n kube-system -l app.kubernetes.io/name=external-dns`
   - Verify IAM role has Route53 permissions
   - Ensure the service/ingress has the correct annotations

2. **Access denied errors:**
   - Verify the IAM policy attached to the role
   - Check IRSA (IAM Roles for Service Accounts) is configured correctly

## Additional Resources

- [Amazon EFS CSI Driver Documentation](https://github.com/kubernetes-sigs/aws-efs-csi-driver)
- [External DNS Documentation](https://github.com/kubernetes-sigs/external-dns)
- [EKS Add-ons Documentation](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html)
