output "pipeline_arn" {
  value       = "${aws_codepipeline.default.arn}"
  description = "Pipeline arn"
}