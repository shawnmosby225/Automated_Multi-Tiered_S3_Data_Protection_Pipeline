# 3. AWS Backup Vault
resource "aws_backup_vault" "vault" {
  name        = var.backup_vault_name
}

# 4. AWS Backup Plan
resource "aws_backup_plan" "daily_plan" {
  name = "Daily-S3-Backup-Plan"
  rule {
    rule_name         = "Daily-S3-Retention-30Days"
    target_vault_name = aws_backup_vault.vault.name
    schedule          = "cron(0 5 ? * * *)"
    enable_continuous_backup = true
    lifecycle {
      delete_after = 30
    }
    copy_action {
      destination_vault_arn = aws_backup_vault.vault.arn
      lifecycle {
        delete_after = 365 
      }
    }
  }
}
# 5. AWS Backup Selection
resource "aws_backup_selection" "s3_selection" {
  name          = "S3-Selection-${var.source_bucket_name}"
  plan_id       = aws_backup_plan.daily_plan.id
  iam_role_arn  = aws_iam_role.backup_role.arn
  selection_tag {  
    type  = "STRINGEQUALS"
    key   = "BackupMe"
    value = "Yes"
  }
}
