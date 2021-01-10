# Allow accepting RA on eth0 when forwarding is enabled
echo "net.ipv6.conf.eth0.accept_ra = 2" > /etc/sysctl.d/eth0-enable-ra.conf

# Install k3s
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--tls-san <hostname> --disable servicelb" sh -

# Create CSR
openssl req -new -new -newkey rsa:2048 -keyout <user>.key -passout pass:client11 -out <user>.csr -subj "/O=admin/CN=<user>"
cat <user>.csr | base64 # put into manifests/csr.yml

# Approve CSR on server
kubectl apply -f csr.yaml
kubectl certificate approve user
kubectl get csr/<user> -o yaml # certificate.status has base64 encoded client cert

# Assign cluster role
kubectl create clusterrolebinding <user>-cluster-admin-binding --clusterrole=cluster-admin --user=<user>
