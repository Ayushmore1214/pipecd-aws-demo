#  PipeCD + Terraform AWS GitOps

> *"I’m 17, and I’m too lazy to manually click buttons in the AWS Console. So I built this."*   — Ayush
<p align="center">
  <img src="https://github.com/pipe-cd/pipecd/blob/master/docs/static/images/logo.png" width="180"/>
</p>
Welcome to the ultimate GitOps flex. This project shows you how to automate AWS infrastructure (S3) using **PipeCD** running inside a local **Kind** cluster. No more "It worked on my machine." Now, it only works in Git.

-----

### 🛠 Prerequisites (The "Don't Forget These" List)

  * **Docker:** The engine under the hood.
  * **kubectl:** Your magic wand for K8s.
  * **Kind:** Kubernetes-in-Docker (The local playground).
  * **AWS Keys:** Your IAM user needs `AmazonS3FullAccess`.
  * **A Fork of this Repo:** Because you can't push to mine\! 😉

-----

### 1️⃣ Level 1: Spin up the Cluster

We’re building a playground. If you mess up, you can just delete it and pretend it never happened.

```bash
kind create cluster --name pipecd-demo
kubectl get nodes # Should show 'Ready' or I'll wait...
```

### 2️⃣ Level 2: The PipeCD Brain (Control Plane)

Let's install the commander. This is the UI where the magic happens.

```bash
kubectl create namespace pipecd
kubectl apply -n pipecd -f https://raw.githubusercontent.com/pipe-cd/pipecd/master/quickstart/manifests/control-plane.yaml
```

> **Fun Fact:** While you wait for pods to be `Running`, know that PipeCD can manage K8s, Terraform, Lambda, AND Cloud Run. It’s basically the Swiss Army knife of CD.

### 3️⃣ Level 3: Port Forward (The Portal)

Open the UI in your browser.

```bash
kubectl port-forward -n pipecd svc/pipecd 8080:8080
```

  * **URL:** `http://localhost:8080`
  * **Project Name:** `quickstart`
  * **User/Pass:** `hello-pipecd` / `hello-pipecd` (Classic security, right?)

### 4️⃣ Level 4: Deploy the Agent (The Muscle)

Go to **Settings \> Pipeds \> Add Piped**. Name it `aws-agent`. Copy your ID and Key.

```bash
curl -s https://raw.githubusercontent.com/pipe-cd/pipecd/master/quickstart/manifests/piped.yaml | \
sed -e 's/<YOUR_PIPED_ID>/PASTE_ID_HERE/g' \
-e 's/<YOUR_PIPED_KEY_DATA>/PASTE_BASE64_KEY_HERE/g' | \
kubectl apply -n pipecd -f -
```

**🚨 Pro Tip:** Wait for the red dot in the UI to turn **GREEN**. If it stays red, check your internet or your coffee levels.

### 5️⃣ Level 5: The "Secret Sauce" (Terraform + AWS)

Now we tell the agent how to talk to AWS. Update the `remote` URL to **your** fork.

```bash
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
      pipedID: YOUR_ID_HERE
      pipedKeyData: YOUR_KEY_HERE
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

# Inject the keys (Don't leak these on stream!)
kubectl set env deployment/piped -n pipecd \
  AWS_ACCESS_KEY_ID="AKIA..." \
  AWS_SECRET_ACCESS_KEY="wJalr..."

kubectl rollout restart deployment piped -n pipecd
```

### 6️⃣ Final Boss: Register the App

In the UI: **Applications \> + ADD \> ADD MANUALLY**.

  * **Kind:** `TERRAFORM` (Don't skip this or nothing works\!)
  * **Platform Provider:** `aws-terraform`
  * **Path:** `infra-s3` (**NO TRAILING SPACES\!** Seriously, I lost an hour to a space character.)
  * **Config File:** `app.pipecd.yaml`

-----

###  The Payoff

Click **SYNC**. Go to the **Deployments** tab. Watch the terminal logs stream in.
If you see `Apply complete!`, go check your AWS Console. An S3 bucket just appeared out of thin air.

-----

### 🧹 The Clean-Up (Don't get billed\!)

1.  **Delete the Bucket:** Go to AWS Console and delete the bucket `pipecd-gitops-demo-ayush-001`.
2.  **Kill the Cluster:**
    ```bash
    kind delete cluster --name pipecd-demo
    ```
    
   


-----

**Made with ❤️ by Ayush More.** If this helped you, give it a ⭐ and find me on [LinkedIn](https://www.google.com/search?q=https://www.linkedin.com/in/ayush-more/)\!

-----

**Does this look like something you'd be proud to show the maintainers?** I can help you generate a cool architecture diagram image to put under the "Architecture" section if you'd like\!
