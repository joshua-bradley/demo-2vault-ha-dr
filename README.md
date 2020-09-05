### walkthrough

### enterprise binaries
```shell

$ export VAULT_DOWNLOAD_URL="https://releases.hashicorp.com/vault/1.5.0+ent/vault_1.5.0+ent_linux_amd64.zip" && export CONSUL_DOWNLOAD_URL="https://releases.hashicorp.com/consul/1.8.1+ent/consul_1.8.1+ent_linux_amd64.zip"
```

```shell
open source binaries

export VAULT_DOWNLOAD_URL="https://releases.hashicorp.com/vault/1.5.3/vault_1.5.3_linux_amd64.zip" && export CONSUL_DOWNLOAD_URL="https://releases.hashicorp.com/consul/1.8.3/consul_1.8.3_linux_amd64.zip"
```

vault operator init -recovery-shares=1 -recovery-threshold=1 2>&1 | tee vault.txt
```
Recovery Key 1: ...

Initial Root Token: ...

Success! Vault is initialized

Recovery key initialized with 1 key shares and a key threshold of 1. Please
securely distribute the key shares printed above.
```

vault status
```
ubuntu@ip-10-0-103-249:~$ vault status
Key                                    Value
---                                    -----
Recovery Seal Type                     shamir
Initialized                            true
Sealed                                 false
Total Recovery Shares                  1
Threshold                              1
Version                                1.5.0+ent
Cluster Name                           vault-cluster-d67543d6
Cluster ID                             bb573127-1d7f-25b4-e69a-1b42d4e3b65e
HA Enabled                             true
HA Cluster                             https://10.0.104.139:8201
HA Mode                                standby
Active Node Address                    https://10.0.104.139:8200
Performance Standby Node               true
Performance Standby Last Remote WAL    0
```

sudo systemctl restart vault

`vault operator unseal`

`consul license put`


*.eu-west-2.elb.amazonaws.com
*.us-west-2.elb.amazonaws.com
*.us-west-2.compute.amazonaws.com
*.eu-west-2.compute.amazonaws.com

[![Maintained by joshua-bradley.io](https://img.shields.io/static/v1?style=flat-square&logo=terraform&label=maintained%20by&message=joshua-bradley.io&color=blueviolet)](https://github.com/joshua-bradley)

```
Error writing data to sys/replication/performance/secondary/enable: Error making API request.

URL: PUT https://127.0.0.1:8200/v1/sys/replication/performance/secondary/enable
Code: 500. Errors:

* 1 error occurred:
	* error response unwrapping secondary token; status code is 400, message is "400 Bad Request"
```

```
Error writing data to sys/replication/performance/secondary/enable: Error making API request.

URL: PUT https://127.0.0.1:8200/v1/sys/replication/performance/secondary/enable
Code: 500. Errors:

* 1 error occurred:
	* error unwrapping secondary token: Post "https://10.0.104.139:8200/v1/sys/wrapping/unwrap": dial tcp 10.0.104.139:8200: i/o timeout
```

touch init-vault.sh && chmod +x init-vault.sh; vi init-vault.sh

```
#!/bin/bash
vault operator init -recovery-shares=1 -recovery-threshold=1 2>&1 | tee vault.txt
sudo systemctl restart vault
sleep 5
vault status
echo -e "\e[1;32mto licence consul run:\e[0m \n\tconsul license put <license>"
echo -e "\e[1;32mto licence vault run:\e[0m \n\tvault write -f /sys/license text=<license>"
```

vault read /sys/license
