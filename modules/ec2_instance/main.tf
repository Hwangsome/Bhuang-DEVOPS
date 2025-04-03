resource "aws_instance" "this" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name
  iam_instance_profile   = var.iam_instance_profile
  user_data              = var.user_data
  
  dynamic "root_block_device" {
    for_each = var.root_block_device != null ? [var.root_block_device] : []
    content {
      volume_size           = lookup(root_block_device.value, "volume_size", 8)
      volume_type           = lookup(root_block_device.value, "volume_type", "gp2")
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", true)
      encrypted             = lookup(root_block_device.value, "encrypted", false)
    }
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device
    content {
      device_name           = ebs_block_device.value.device_name
      volume_size           = lookup(ebs_block_device.value, "volume_size", 8)
      volume_type           = lookup(ebs_block_device.value, "volume_type", "gp2")
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", true)
      encrypted             = lookup(ebs_block_device.value, "encrypted", false)
    }
  }

  tags = merge(
    { "Name" = var.name },
    var.tags
  )
}
