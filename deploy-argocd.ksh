#! /usr/bin/env bash 

# Wrapper script to automate ArgoCD deploy 
# - attempts to setup an app of apps configuration,
# - with applications being defined in the argocd-lab-apps repo
# 
# Script assumes ... 
# - that the a "argocd" cluster already exists 
# - and that the default minikube ingress controller addon has been enabled 
# - that the ingress TLS secret has already been added to the ingress controller
# - and that iptable roules have alrady been updated to facilitate comms between the
#   "argocd" cluster and the target "minikube" cluster
# See ME-8 for more details 

echo -e `date` "- Wrapper script to deploy ArgoCD into a "argocd" minikube cluster \n" 

# Check to make sure the "argocd" kubectl context exists, if so proceed, if not abort 
if [ 'kubectl config get-contexts | grep argocd' ]; then 
  echo "The argocd kubectl context exists, assuming safe to proceed ... "
  kubectl --context argocd create namespace argocd
  kustomize build kustomize/ | kubectl --context argocd -n argocd apply -f -
else 
  echo "The argocd kubctl context doesn't exist, please check minikube cluster setup."
fi

# Post-install cfg 

# Add the connection to gitlab repo with ssh key reference 
# Assumes user is already loggd in and authenticated to the argocd server 
# Run the following command to login and authenticate 
# > argocd login trg.argocd.demo 

argocd repo add git@gitlab.com:trevgall1/python-cicd.git --ssh-private-key-path ~/.ssh/id_ed25519

