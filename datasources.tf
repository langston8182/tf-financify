data "archive_file" "zip_lambdas" {
  for_each = fileset("./modules/lambda/files/", "*.mjs")
  output_path = "./modules/lambda/files/${each.value}.zip"
  type        = "zip"
  source_file = "./modules/lambda/files/${each.value}"
}