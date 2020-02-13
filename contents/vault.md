# おまけ vaultの設定

```shell
vault secrets enable aws

vault write aws/config/root \
  access_key=********************* \
  secret_key=**************************************** \
  region=ap-northeast-1

vault write aws/roles/tfrole \
  credential_type=iam_user \
  policy_document=-<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  {
    "Effect": "Allow",
    "Action": [
    "ec2:*", "elasticloadbalancing:*", "iam:*"
    ],
    "Resource": "*"
    }
  ]
}
EOF
```

```shell
path "aws/creds/tfrole" {
  capabilities = ["read"]
}
path "auth/token/create" {
  capabilities = ["create","update"]
}

vault policy write tfrole config/tfrole.hcl
```


```shell
vault auth enable approle

vault write auth/approle/role/tfrole \
    token_policies=tfrole \
    token_ttl=1h \
    token_max_ttl=4h
```

```shell
vault read auth/approle/role/tfrole/role-id

vault write -f auth/approle/role/tfrole/secret-id
```
