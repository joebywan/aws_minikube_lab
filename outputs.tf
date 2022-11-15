## EC2 Outputs
output "ec2_tags" {
  value       = aws_instance.master_ec2.tags_all
  description = "Tags on the instance"
}

output "ec2_ip" {
  value       = aws_instance.master_ec2.public_ip
  description = "Public IP of the instance"
}

output "ec2_public_dns" {
  value       = aws_instance.master_ec2.public_dns
  description = "Public DNS of the instance"
}