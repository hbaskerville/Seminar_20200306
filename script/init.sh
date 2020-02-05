#!/bin/bash

### Set VAULT_ADDR
echo "export VAULT_ADDR='http://0.0.0.0:8200'" >> /etc/profile

### Set Vault config
cat > /opt/vault/config/vault-config.hcl <<EOF
storage "file" {
   path = "/opt/vault/data"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

ui = true
EOF

### Stating Vault server & init sequence
export VAULT_ADDR='http://0.0.0.0:8200'
/opt/vault/bin/vault server -config /opt/vault/config/vault-config.hcl &
sleep 45
/opt/vault/bin/vault operator init > /tmp/vault_init.log 2>&1
sleep 10

### Unsealing Vault
cat /tmp/vault_init.log | while read line
do
  if [[ $line =~ "Unseal Key "  ]]; then
    echo "/opt/vault/bin/vault operator unseal ${line##* }" >> /tmp/vault_unseal.log
    /opt/vault/bin/vault operator unseal ${line##* } >> /tmp/vault_unseal.log 2>&1
    sleep 1
  fi
done

### Login Vault root token
cat /tmp/vault_init.log | while read line
do
  if [[ $line =~ "Initial Root Token:" ]]; then
    echo "/opt/vault/bin/vault login ${line##* }" >> /tmp/vault_unseal.log
    /opt/vault/bin/vault login ${line##* } >> /tmp/vault_unseal.log 2>&1
  fi
done

### Create root token of root id
echo "/opt/vault/bin/vault token create -id=root" >> /tmp/vault_unseal.log
/opt/vault/bin/vault token create -id=root >> /tmp/vault_unseal.log 2>&1
