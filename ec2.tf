# Spot request for the instance considering it's just a throwaway?
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/spot_instance_request
# https://aws.amazon.com/ec2/spot/pricing/
# https://aws.amazon.com/ec2/pricing/on-demand/

# resource "aws_spot_instance_request" "spot_ec2" {
#   ami                    = data.aws_ami.ubuntu_linux_v2204_ami.id # Ubuntu 22.04 AMI
#   instance_type          = "t3a.large"
#   key_name               = var.ec2_key
#   iam_instance_profile   = "AmazonSSMRoleForInstancesQuickSetup"
#   vpc_security_group_ids = [aws_security_group.security_group.id]
#   subnet_id              = var.subnet_id
#   user_data              = file("./userdata_ubuntu.sh")

#   root_block_device {
#     volume_type = "gp3"
#     volume_size = 20
#   }

#   tags = merge({ Name = "${var.naming_prefix}-${data.aws_ami.ubuntu_linux_v2204_ami.name}" }, var.tags)

#   # Spot specific settings
#   spot_type = "one-time"
#   spot_price = "0.03"
#   # wait_for_fulfillment = false
#   # block_duration_minutes = 60
#   # launch_group = "specify here"
#   # valid_from = "YYYY-MM-DDTHH:MM:SSZ"
#   # valid_to = "YYYY-MM-DDTHH:MM:SSZ"
# }

#----- Instance with User Data & File Provisioner ------ #
resource "aws_instance" "master_ec2" {
  # ami                    = data.aws_ami.aws_linux_ami.id # Base Amazon Linux 2`
  ami                    = data.aws_ami.ubuntu_linux_v2204_ami.id # Ubuntu 22.04 AMI
  instance_type          = "t3a.large"
  key_name               = var.ec2_key
  iam_instance_profile   = "AmazonSSMRoleForInstancesQuickSetup"
  vpc_security_group_ids = [aws_security_group.security_group.id]
  subnet_id              = var.subnet_id
  user_data              = file("./userdata_ubuntu.sh")

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
  }

  tags = merge({ Name = "${var.naming_prefix}-${data.aws_ami.ubuntu_linux_v2204_ami.name}" }, var.tags)
}

output "ec2_ip_address" {
  value = aws_instance.master_ec2.public_ip
}

# # ----- Hardened EC2 Instances ------ #
# resource "aws_instance" "hardened_instance" {
#   ami                    = "ami-007232fd5793a24d4" # Hardend EKS Amazon Linux 2
#   instance_type          = "t2.large"
#   key_name               = var.ec2_key
#   vpc_security_group_ids = [aws_security_group.security_group.id]
#   subnet_id              = var.public_subnet
#   tags = merge({ Name = "tunny-hardened-image" }, var.tags)

# }

# # ----- Hardened EC2 Instances ------ #
# resource "aws_instance" "hardened_instance" {
#   ami                    = "ami-03acaa437d72fbe7a" # CIS Marketplace Amazon Linux 2
#   instance_type          = "t2.large"
#   key_name               = var.ec2_key
#   vpc_security_group_ids = [aws_security_group.security_group.id]
#   subnet_id              = var.public_subnet
#   tags = merge({ Name = "tunny-hardened-image" }, var.tags)

# }
# # ----- Kali EC2 Instances ------ #
# resource "aws_instance" "hardened_instance" {
#   ami                    = "ami-0df88e2f672b904c0" # CIS Marketplace Amazon Linux 2
#   instance_type          = "t2.large"
#   key_name               = var.ec2_key
#   vpc_security_group_ids = [aws_security_group.security_group.id]
#   subnet_id              = var.public_subnet
#   tags = merge({ Name = "tunny-kali-image" }, var.tags)

# }

# # <--- Trade Ledger Hardened AMI --->
# resource "aws_instance" "trade_ledger_instance" {
#   ami = "ami-038f713935479ad4a" # Trade Ledger hardened EKS image
#   instance_type          = "t2.large"
#   key_name               = var.ec2_key
#   vpc_security_group_ids = [aws_security_group.security_group.id]
#   subnet_id              = var.public_subnet
#   tags = merge({ Name = "tunny-trade-ledger-hardend-eks-image" }, var.tags)

# }




# inspec exec https://github.com/dev-sec/cis-dil-benchmark.git -t ssh://ec2-user@52.65.165.202 -i ~/.ssh/sandpit-tunny.pem

# Base Linux AMI:
# Profile Summary: 90 successful controls, 90 control failures, 51 controls skipped
# Test Summary: 597 successful, 273 failures, 73 skipped

# Hardend EKS Linux AMI:
# Profile Summary: 124 successful controls, 56 control failures, 51 controls skipped
# Test Summary: 672 successful, 184 failures, 71 skipped

# CIS Amazon Linux 2 Marketplace AMI:
# Profile Summary: 122 successful controls, 58 control failures, 51 controls skipped
# Test Summary: 670 successful, 181 failures, 72 skipped