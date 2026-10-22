locals {
  mandatory_tags_without_protected_keys = {
    for key, value in var.mandatory_tags : key => value
    if !contains(["Project", "Environment"], key)
  }
}
