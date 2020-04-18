
variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-2"
}

variable "aws_account_id" {
  description = "The 12 digit AWS account ID."
}

variable "bucket_name" {
    description = "The name of the bucket to store your backups in."
}

variable "function_name" {
    description = "The name of the Lambda function"
    default     = "hymnal-backup"
}

variable "mongo_cluster_shard" {
    description = "Name of the cluster shards in the form `clustername-shard-00-00-xxxxx.mongodb.net,clustername-shard-00-01-xxxxx.mongodb.net,clustername-shard-00-02-xxxxx.mongodb.net`."
}

variable "mongo_db_name" {
    description = "The name of the database."
}

variable "mongo_user" {
    description = "The user for the database."
}

variable "mongo_pw" {
    description = "The password for the database."
}

variable "mongo_replica_set" {
    description = "Name of the replica set in the form `clustername-shard-0`"
}