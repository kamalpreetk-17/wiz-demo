output "public_ip" { value = aws_instance.mongo_vm.public_ip }
output "private_ip" { value = aws_instance.mongo_vm.private_ip }