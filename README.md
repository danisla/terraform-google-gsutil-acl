# Terraform module to modify GCS bucket ACL

This module lets you modify existing bucket GCS bucket ACL entities. The `google_storage_bucket_acl` works best with buckets created by Terraform and have a fully Terraform-managed ACL. This module lets you make incremental adjustmenst to the ACL of existing buckets, or those created with Terraform using the `gsutil acl` command from the Google Cloud SDK.

