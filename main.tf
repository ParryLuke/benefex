# Create security group for blog instances
resource "aws_security_group" "blog_sg" {
  name        = "${var.name_prefix}-sg"
  description = "Security group for ${var.name_prefix} EC2 instances"

  # Office RDP
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [var.office_ip]
  }

  # Allow traffic from ALB
  ingress {
    description     = "Allow HTTP traffic from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.blog_alb_sg.id]
  }

  # Allow outbound connections
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
  dynamic "block_device_mappings" {
    for_each = var.volume_details
    content {
      device_name = block_device_mappings.value.device_name

      ebs {
        volume_size           = block_device_mappings.value.volume_size
        volume_type           = "gp3"
        delete_on_termination = true
        encrypted             = true

        # Conditionally include snapshot_id if it's not empty
        snapshot_id = length(block_device_mappings.value.snapshot_id) != "" ? block_device_mappings.value.snapshot_id : null
      }
    }
  }

  # Dynamically set tags for launch template resources (instance, volume)
  dynamic "tag_specifications" {
    for_each = toset(["instance", "volume"])

    content {
      resource_type = tag_specifications.value
      tags          = data.aws_default_tags.current.tags
    }
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

  # Auto Scaling group and instances do not inherit tags from provider
  dynamic "tag" {
    for_each = data.aws_default_tags.current.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  target_group_arns = [aws_lb_target_group.blog_tg.arn]
}

# Create security group for ALB - Allows HTTPS connections
resource "aws_security_group" "blog_alb_sg" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Security group for ${var.name_prefix} ALB"

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

# Add an ALB for the instances
resource "aws_lb" "blog_alb" {
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.blog_alb_sg.id]
  subnets            = data.aws_subnets.default_vpc_subnets.ids

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "blog_tg" {
  name     = "${var.name_prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
}

# Add ALB listener for HTTPS
resource "aws_lb_listener" "blog_listener" {
  load_balancer_arn = aws_lb.blog_alb.arn
  port              = 443
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blog_tg.arn
  }
}

# Add an IAM role for EBS snapshots via Lifecycle Manager
resource "aws_iam_role" "dlm_role" {
  name = "DLMServiceRole"

  # Attach Lifecycle Manager policy
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSDataLifecycleManagerServiceRole"]

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "dlm.amazonaws.com"
      },
      Effect = "Allow"
    }]
  })
}

# Add the Lifecycle policy for the daily EBS snapshots
resource "aws_dlm_lifecycle_policy" "ebs_backup" {
  description        = "EBS Snapshot Lifecycle Policy"
  execution_role_arn = aws_iam_role.dlm_role.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name      = "DailySnapshot"
      copy_tags = true
      create_rule {
        interval      = 24 # Back up every day
        interval_unit = "HOURS"
        times         = ["00:00"] # Back up at midnight
      }

      retain_rule {
        count = 7 # Retain for 1 week
      }
    }

    target_tags = data.aws_default_tags.current.tags
  }
}
