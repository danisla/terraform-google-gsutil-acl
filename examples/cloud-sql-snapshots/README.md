# Cloud SQL Export Terraform Example

Example showing how to use the `terraform-google-gsutil-acl` module to add an ACL for a Cloud SQL instance allowing the instance service account write permission to import/export data to a GCS bucket.

## Create the GCS bucket

1. Create GCS bucket for database export:

```
BUCKET=$(gcloud config get-value project)-sql-acl-example
gsutil mb gs://${BUCKET}
```

2. Add bucket name to tfvars file:

```
cat > terraform.tfvars <<EOF
write_url = "gs://${BUCKET}"
read_url = "gs://${BUCKET}/snapshots/world.sql.gz"
EOF

```

## Run terraform

```
terraform init
terraform apply
```

## Import data

1. Copy public dataset to GCS bucket:

```
curl -LO http://downloads.mysql.com/docs/world.sql.gz

BUCKET=$(gcloud config get-value project)-sql-acl-example
gsutil cp world.sql.gz gs://${BUCKET}/snapshots/world.sql.gz
```

2. Import using gcloud:

```
gcloud sql import sql $(terraform output instance_name) \
  gs://${BUCKET}/snapshots/world.sql.gz --database default
```

## Export data

1. Export data using gcloud:

```
gcloud sql export sql $(terraform output instance_name) \
  gs://${BUCKET}/snapshots/world-export.sql.gz --database default
```

## Cleanup

1. Remove the ACL and resources created by terraform:

```
TF_VAR_acl_action="del" terraform destroy
```