################################################################################
# RDS Module - Managed Relational Database Service
################################################################################

resource "aws_db_instance" "main" {
  identifier = var.identifier

  # Engine Configuration
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  allocated_storage    = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type         = var.storage_type
  storage_encrypted    = var.storage_encrypted
  kms_key_id           = var.kms_key_id
  iops                 = var.iops

  # Database Configuration
  db_name  = var.database_name
  username = var.master_username
  password = var.master_password != "" ? var.master_password : random_password.master[0].result
  port     = var.port

  # Network Configuration
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  publicly_accessible    = var.publicly_accessible

  # High Availability
  multi_az               = var.multi_az
  availability_zone      = var.multi_az ? null : var.availability_zone

  # Backup Configuration
  backup_retention_period   = var.backup_retention_period
  backup_window             = var.backup_window
  copy_tags_to_snapshot     = true
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.identifier}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  delete_automated_backups  = var.delete_automated_backups

  # Maintenance
  maintenance_window          = var.maintenance_window
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  apply_immediately          = var.apply_immediately

  # Performance Insights
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  performance_insights_kms_key_id      = var.performance_insights_kms_key_id

  # Enhanced Monitoring
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring[0].arn : null

  # Logging
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  # Deletion Protection
  deletion_protection = var.deletion_protection

  # Parameter Group
  parameter_group_name = var.parameter_group_name != "" ? var.parameter_group_name : aws_db_parameter_group.main[0].name

  # Option Group (for Oracle & SQL Server)
  option_group_name = var.option_group_name

  tags = merge(
    var.tags,
    {
      Name = var.identifier
    }
  )

  lifecycle {
    ignore_changes = [
      password,
      final_snapshot_identifier
    ]
  }
}

################################################################################
# Random Password for Master User
################################################################################

resource "random_password" "master" {
  count   = var.master_password == "" ? 1 : 0
  length  = 32
  special = true
}

resource "aws_secretsmanager_secret" "db_password" {
  count       = var.master_password == "" ? 1 : 0
  name        = "${var.identifier}-master-password"
  description = "Master password for RDS instance ${var.identifier}"

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "db_password" {
  count         = var.master_password == "" ? 1 : 0
  secret_id     = aws_secretsmanager_secret.db_password[0].id
  secret_string = jsonencode({
    username = var.master_username
    password = random_password.master[0].result
    engine   = var.engine
    host     = aws_db_instance.main.address
    port     = aws_db_instance.main.port
    dbname   = var.database_name
  })
}

################################################################################
# Parameter Group
################################################################################

resource "aws_db_parameter_group" "main" {
  count  = var.parameter_group_name == "" ? 1 : 0
  name   = "${var.identifier}-params"
  family = var.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", "immediate")
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.identifier}-params"
    }
  )
}

################################################################################
# IAM Role for Enhanced Monitoring
################################################################################

resource "aws_iam_role" "rds_monitoring" {
  count              = var.monitoring_interval > 0 ? 1 : 0
  name               = "${var.identifier}-rds-monitoring-role"
  assume_role_policy = data.aws_iam_policy_document.rds_monitoring[0].json

  tags = var.tags
}

data "aws_iam_policy_document" "rds_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count      = var.monitoring_interval > 0 ? 1 : 0
  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
