// Mongo  # to-do: make passwords dynamic (like RMN)
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
