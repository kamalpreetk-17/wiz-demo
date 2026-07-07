resource "aws_iam_role" "vm_role" {
  name = "${var.environment}-vm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17", Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" } }]
  })
}
resource "aws_iam_role_policy_attachment" "ec2_access" {
  role       = aws_iam_role.vm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}
resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.vm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_instance_profile" "vm_profile" {
  name = "${var.environment}-profile"
  role = aws_iam_role.vm_role.name
}

resource "aws_security_group" "mongo_sg" {
  name   = "${var.environment}-mongo-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_security_group_ingress_rule" "mongo_from_eks_nodes" {
  security_group_id            = aws_security_group.mongo_sg.id
  referenced_security_group_id = var.k8s_node_security_group_id
  from_port                    = 27017
  to_port                      = 27017
  ip_protocol                  = "tcp"
  description                  = "Allow MongoDB access only from EKS worker nodes"
}

data "aws_ami" "ubuntu_outdated" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's official AWS account ID

  filter {
    name   = "name"
    # This string looks for the official, stable Ubuntu 22.04 LTS image
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "mongo_vm" {
  ami                         = data.aws_ami.ubuntu_outdated.id
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.mongo_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.vm_profile.name
  
  tags = { Name = "${var.environment}-MongoDB" }

    user_data = <<-EOF
              #!/bin/bash
              apt-get update && apt-get install -y mongodb awscli
              
              # Modify the YAML formatted mongod.conf to listen on all IPs
              sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongodb.conf
              
              # Restart the service to apply changes
              systemctl restart mongodb
              
              cat << 'SCRIPT' > /usr/local/bin/mongo-backup.sh
              #!/bin/bash
              mongodump --out /tmp/mongobackup
              aws s3 sync /tmp/mongobackup s3://${var.backup_bucket_name}/daily/
              SCRIPT
              chmod +x /usr/local/bin/mongo-backup.sh
              echo "0 2 * * * root /usr/local/bin/mongo-backup.sh" > /etc/cron.d/mongobackup
              /usr/local/bin/mongo-backup.sh
              EOF
}