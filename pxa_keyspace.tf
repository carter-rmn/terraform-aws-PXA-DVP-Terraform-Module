resource "aws_keyspaces_keyspace" "keyspace" {
  name = "${var.PROJECT_KEYSPACE_NAME}"

  tags = {
    Name        = "${var.PROJECT_KEYSPACE_NAME}"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

resource "aws_keyspaces_table" "carter_analytics_events" {
  keyspace_name = aws_keyspaces_keyspace.keyspace.name
  table_name    = "carter_analytics_events"

  schema_definition {
    partition_key {
      name = "client_id"
    }
    clustering_key {
      name = "created_at"
      order_by = "DESC"
    }
    clustering_key {
      name = "event_id"
      order_by = "ASC"
    }
    column {
      name = "client_id"
      type = "text"
    }
    column {
      name = "created_at"
      type = "timestamp"
    }
    column {
      name = "event_id"
      type = "uuid"
    }
    column {
      name = "event_name"
      type = "text"
    }
    column {
      name = "event_properties"
      type = "map<text, text>"
    }
    column {
      name = "user_properties"
      type = "map<text, text>"
    }
    column {
      name = "meta_properties"
      type = "map<text, text>"
    }
    column {
      name = "utm_parameters"
      type = "map<text, text>"
    }
    column {
      name = "channel"
      type = "map<text, text>"
    }
    column {
      name = "referrer"
      type = "text"
    }
    column {
      name = "session"
      type = "text"
    }
    column {
      name = "updated_at"
      type = "timestamp"
    }
  }

  point_in_time_recovery {
    status = "ENABLED"
  }

  client_side_timestamps {
    status = "ENABLED"
  }

  tags = {
    Name        = "${local.pxa_project_name}_${var.PROJECT_ENV}_carter_analytics_events"
    Project     = local.pxa_project_name
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}
