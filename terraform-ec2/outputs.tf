output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.docker_host.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.docker_host.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.docker_host.public_dns
}

output "ssh_command" {
  description = "Command to SSH into the instance"
  value       = "ssh -i ${file(var.public_key_path)} ubuntu@${aws_instance.docker_host.public_ip}"
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.main.id
}

output "key_pair_name" {
  description = "Name of the AWS key pair"
  value       = aws_key_pair.deployer.key_name
}

output "ami_id" {
  description = "ID of the Ubuntu AMI used"
  value       = data.aws_ami.ubuntu.id
}
