# -----------------------------
# EC2 IAM Role for EKS Access
# -----------------------------
resource "aws_iam_role" "ec2_eks_access_role" {
  name = "EC2EKSAccessRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role_policy" "allow_describe_cluster" {
  name = "AllowEKSDescribe"
  role = aws_iam_role.ec2_eks_access_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "eks:DescribeCluster"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "EC2EKSAccessProfile"
  role = aws_iam_role.ec2_eks_access_role.name
}
resource "aws_iam_role_policy_attachment" "eks_access_attach" {
  role       = aws_iam_role.ec2_eks_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


# -----------------------------
# Security Group
# -----------------------------
resource "aws_security_group" "my-sg" {
  name        = "SonarserverPorts"
  description = "Sonar Server Ports"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH Port"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP Port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS Port"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Etcd Cluster"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Grafana Port"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kube API Server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins Port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SonarQube Port"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Prometheus Port"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Prometheus Metrics Port"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes Ports"
    from_port   = 10250
    to_port     = 10260
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "K8s NodePort Range"
    from_port   = 30000
    to_port     = 32767
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

# -----------------------------
# EC2 Instance
# -----------------------------
resource "aws_instance" "my-ec2" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.ec2_key_pair
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.my-sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_size = var.volume_size
  }

  tags = {
    Name = var.server_name
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      private_key = var.ec2_private_key
      user        = "ubuntu"
      host        = self.public_ip
    }

    inline = [
      # Install AWS CLI
      "sudo apt install unzip -y",
      "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'",
      "unzip awscliv2.zip",
      "sudo ./aws/install",

      # Install Docker
      "sudo apt-get update -y",
      "sudo apt-get install -y ca-certificates curl",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc",
      "sudo chmod a+r /etc/apt/keyrings/docker.asc",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update -y",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      "sudo usermod -aG docker ubuntu",
      "sudo chmod 777 /var/run/docker.sock",
      "docker --version",

      # Install SonarQube
      "docker run -d --name sonar -p 9000:9000 sonarqube:lts-community",

      # Install Trivy
      "sudo apt-get install -y wget apt-transport-https gnupg",
      "wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null",
      "echo 'deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main' | sudo tee -a /etc/apt/sources.list.d/trivy.list",
      "sudo apt-get update -y",
      "sudo apt-get install trivy -y",

      # Install Kubectl
      "curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.4/2024-09-11/bin/linux/amd64/kubectl",
      "curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.4/2024-09-11/bin/linux/amd64/kubectl.sha256",
      "sha256sum -c kubectl.sha256",
      "chmod +x ./kubectl",
      "sudo mv ./kubectl /usr/local/bin/kubectl",
      "kubectl version --client",

      # Install Helm
      "wget https://get.helm.sh/helm-v3.16.1-linux-amd64.tar.gz",
      "tar -zxvf helm-v3.16.1-linux-amd64.tar.gz",
      "sudo mv linux-amd64/helm /usr/local/bin/helm",
      "helm version",

      # Install ArgoCD
      "VERSION=$(curl -L -s https://raw.githubusercontent.com/argoproj/argo-cd/stable/VERSION)",
      "curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/v$VERSION/argocd-linux-amd64",
      "sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd",
      "rm argocd-linux-amd64",

      # Install Java 17
      "sudo apt update -y",
      "sudo apt install openjdk-17-jdk openjdk-17-jre -y",
      "java -version"
    ]
  }
}

# -----------------------------
# Outputs
# -----------------------------
output "SERVER-SSH-ACCESS" {
  value = "ubuntu@${aws_instance.my-ec2.public_ip}"
}

output "PUBLIC-IP" {
  value = aws_instance.my-ec2.public_ip
}

output "PRIVATE-IP" {
  value = aws_instance.my-ec2.private_ip
}
