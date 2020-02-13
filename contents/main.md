# main.tf の解説（一部）

### はじめに
Terrafomのテンプレートファイル（tfconfig）はHCL (HashiCorp Configuration Language) で記載する必要があります。　　
リファレンスは以下にあります。必要に応じて参照してください。  
https://www.terraform.io/docs/index.html
https://github.com/hashicorp/hcl

### main.tfの解説
Terraformの動作バージョンの指定をしています。今回はVer0.21以上を指定してます。
```
terraform {
  required_version = "~> 0.12"
}
```

Terraformのaws providerを設定しています。  
Terraformがawsのリソースを操作する際に使用するシークレット情報が記載されています。  
ここには、`data.vault_aws_access_credentials....`と記載されており、変数として別の情報を参照していることがわかります。  
シークレット以外にもリージョンも指定しています。  
`var.region`のvar.は変数として解釈されます。変数はvariables.tfに記載しています。
```
provider "aws" {
  access_key = data.vault_aws_access_credentials.aws_creds.access_key
  secret_key = data.vault_aws_access_credentials.aws_creds.secret_key
  region     = var.region
}
```

Terraformのvault providerを設定しています。  
Terraformがvaultへアクセスする情報が記載されています。  
```
provider "vault" {
  address = var.vault_addr
  auth_login {
    path = "auth/approle/login"
    parameters = {
      role_id   = var.login_approle_role_id
      secret_id = var.login_approle_secret_id
    }
  }
}
```

```
data "vault_aws_access_credentials" "aws_creds" {
  backend = "aws"
  role = "tfrole"
}
```

```
data "vault_generic_secret" "aws" {
  path = "aws/creds/tfrole"
}
```
