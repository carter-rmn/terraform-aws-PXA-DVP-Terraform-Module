// Mongo
resource "random_password" "mongo_pxa_root_password" {
  length  = 64
  special = false
}
resource "random_password" "mongo_pxa_app_password" {
  length  = 64
  special = false
}
resource "random_password" "mongo_pxa_viewer_password" {
  length  = 64
  special = false
}
# resource "random_password" "mongo" {
#   for_each = { for item in local.passwords.mongo : "${item.db_name}_${item.username}" => item }
#   length   = 64
#   special  = false
# }
