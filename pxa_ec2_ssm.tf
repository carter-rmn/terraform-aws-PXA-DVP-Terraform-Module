data "aws_ssm_document" "existing" {
  name            = "SSM-SessionManagerRunShell-Ubuntu"
  document_format = "JSON"
}

resource "aws_ssm_document" "ssm_document" {
  count           = length(var.ec2.instances) > 0 && try(data.external.ssm_doc_check[0].result.exists, "false") == "false" ? 1 : 0
  name            = "SSM-SessionManagerRunShell-Ubuntu"
  document_type   = "Session"
  document_format = "JSON"
  update_existing = true 
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
