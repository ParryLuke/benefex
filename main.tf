# Create security group for blog instances in the default VPC - Allows HTTPS and RDP connection from office IP
resource "aws_security_group" "blog_sg" {
  name        = "${var.name_prefix}-sg"
  description = "Security group for ${var.name_prefix} EC2 instances"

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [var.office_ip]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

# Create the launch template for the Auto Scaling group, AMI is selected dynamically 
resource "aws_launch_template" "blog_launch_template" {
  name_prefix            = "${var.name_prefix}-"
  image_id               = data.aws_ami.ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.blog_sg.id]

  # Provide extra storage per instance, separate to root volume
  block_device_mappings {
    device_name = "/dev/sdb"

    ebs {
      volume_size           = var.volume_size
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  block_device_mappings {
    device_name = "/dev/sdc"

    ebs {
      volume_size           = var.volume_size
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  # Define tags for the root EBS volume as this is not inherited from the provider's default_tags
  tag_specifications {
    resource_type = "volume"
    tags          = var.default_tags
  }
}

# Auto scaling group, availability zones are set dynamically from those available in the region
resource "aws_autoscaling_group" "blog_asg" {
  name_prefix        = "${var.name_prefix}-"
  availability_zones = data.aws_availability_zones.available.names
  desired_capacity   = var.desired_capacity
  min_size           = var.min_size
  max_size           = var.max_size

  launch_template {
    id = aws_launch_template.blog_launch_template.id
  }

  tag {
    key                 = var.default_tag_asg_label
    value               = var.default_tag_asg_value
    propagate_at_launch = true
  }
}
