resource "random_password" "mongo" {
  for_each = { for user, username in local.databases.mongo.pxa.users : "pxa_mongo_${user}" => user }
  length   = 64
  special  = false
}
