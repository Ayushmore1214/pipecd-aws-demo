## 🚀 PipeCD + Terraform AWS GitOps Demo

This project demonstrates how to use **PipeCD** to manage AWS infrastructure (S3 Bucket) using a GitOps workflow. The entire Control Plane and Piped Agent run inside a local **Kind** cluster.

### 🛠 Prerequisites
* [Docker](https://docs.docker.com/get-docker/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)
* [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/)
* AWS Account & IAM User Keys
* Terraform

---

### 1. Setup Local Kubernetes
```bash
# Create the cluster
kind create cluster --name pipecd-demo

# Verify cluster is ready
kubectl get nodes
```

### 2. Install PipeCD Control Plane
```bash
# Create namespace
kubectl create namespace pipecd

# Apply manifests
kubectl apply -n pipecd -f https://raw.githubusercontent.com/pipe-cd/pipecd/master/quickstart/manifests/control-plane.yaml

# Wait for pods to be 'Running'
kubectl get pods -n pipecd -w
```

### 3. Expose the UI
```bash
kubectl port-forward -n pipecd svc/pipecd 8080:8080
```
> **Login Credentials:** > **Project:** `quickstart` | **User:** `hello-pipecd` | **Pass:** `hello-pipecd`

### 4. Configure the Piped Agent
1. Go to **Settings > Pipeds > Add Piped**. Name it `aws-agent`.
2. Copy the **Piped ID** and **Base64 Piped Key**.
3. Run the following to deploy the agent (Replace placeholders):

```bash
curl -s https://raw.githubusercontent.com/pipe-cd/pipecd/master/quickstart/manifests/piped.yaml | \
sed -e 's/<YOUR_PIPED_ID>/YOUR_ID_HERE/g' \
-e 's/<YOUR_PIPED_KEY_DATA>/YOUR_BASE64_KEY_HERE/g' | \
kubectl apply -n pipecd -f -
```
After this check ui for the red dot to turn green 

### 5. Add Terraform & AWS Keys
Apply the configuration to enable Terraform and inject your AWS credentials:

```bash
# Apply the ConfigMap (Update the GitHub URL to your fork!)
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: piped
  namespace: pipecd
data:
  piped-config.yaml: |-
    apiVersion: pipecd.dev/v1beta1
    kind: Piped
    spec:
      projectID: quickstart
      pipedID: YOUR_PIPED_ID_HERE
      pipedKeyData: YOUR_BASE64_KEY_HERE
      apiAddress: pipecd:8080
      repositories:
        - repoId: aws-demo-repo
          remote: https://github.com/YOUR_USERNAME/pipecd-aws-demo.git
          branch: main
      cloudProviders:
        - name: aws-terraform
          type: TERRAFORM
          config: {}
EOF

# Inject AWS Keys
kubectl set env deployment/piped -n pipecd \
  AWS_ACCESS_KEY_ID="YOUR_KEY" \
  AWS_SECRET_ACCESS_KEY="YOUR_SECRET"

# Restart to apply changes
kubectl rollout restart deployment piped -n pipecd
```

### 6. Register Application in UI
got to apllication click add and then click manually
* **Kind:** `TERRAFORM`
* **Platform Provider:** `aws-terraform`
* **Repository:** `aws-demo-repo`
* **Path:** `infra-s3`
* piped : slect what it comes
* config file : app.pipecd.yaml
* click save

  ### Check logs and s3 buect in aws
  * click on the application then aws-s3-demo
  * wait 2-3 mins checl logs and boom you deplyed a s3 bucket on aws through pipecd
  * Checl aws console 

  ### Cleanup
  * go into the aws console and delete the s3 bucket we created
  * Kill the Kubernetes Cluster
This will wipe out the PipeCD Control Plane, the Piped Agent, and all the configurations we spent today fixing. It’s a total reset:

Bash
kind delete cluster --name pipecd-demo
---

**Would you like me to add a "Troubleshooting" section to the README based on the 'Space Bug' and 'Vim errors' we fixed today?**
