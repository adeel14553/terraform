# Provider can be any vendor depend on client google,azure etc
provider "aws" {
  region = "us-east-1"
  access_key = "AKIAUYV23DCAO55TNZWO"
  secret_key = "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"
}


# 1. createvpc
# 2. Create ig
# 3. Create custom rt
# 4. Creat subnet
# 5. associat subnet with rt
# 6. sg to allow port 22 443 80
# 7. creat network interface with ip
# 8. assign elastic ip to network interface
# 9. create ubuntu server and install apache
