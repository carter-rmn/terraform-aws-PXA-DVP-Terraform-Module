resource "aws_ssm_document" "ssm_document" {
  name            = "SSM-SessionManagerRunShell-Ubuntu"
  document_type   = "Session"
  document_format = "JSON"
  content = jsonencode({
    "schemaVersion" : "1.0",
    "description" : "Session Manager document for EC2 instances with ubuntu user",
    "sessionType" : "Standard_Stream",
    "inputs" : {
      "s3BucketName" : "",
      "s3KeyPrefix" : "",
      "s3EncryptionEnabled" : true,
      "cloudWatchLogGroupName" : "",
      "cloudWatchEncryptionEnabled" : true,
      "idleSessionTimeout" : "20",
      "maxSessionDuration" : "",
      "cloudWatchStreamingEnabled" : true,
      "kmsKeyId" : "",
      "runAsEnabled" : true,
      "runAsDefaultUser" : "ubuntu",
      "shellProfile" : {
        "windows" : "",
        "linux" : ""
      }
    }
  })
}