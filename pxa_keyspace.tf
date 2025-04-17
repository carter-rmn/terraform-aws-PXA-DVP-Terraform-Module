resource "aws_keyspaces_keyspace" "carter_analytics" {
  name = replace("${local.pxa_prefix}-keyspace-carter-analytics", "-", "_")

  tags = {
    Name        = "${local.pxa_prefix}-keyspace-carter-analytics"
    Project     = "${local.pxa_project_name}"
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}

resource "aws_keyspaces_table" "carter_analytics_events" {
  keyspace_name = aws_keyspaces_keyspace.carter_analytics.name
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
    column {
      name = "utm_parameter_arr"
      type = "frozen<list<frozen<map<text, text>>>>"
    }
  }

  point_in_time_recovery {
    status = "ENABLED"
  }

  client_side_timestamps {
    status = "ENABLED"
  }

  tags = {
    Name        = "${local.pxa_prefix}-keyspace-table-carter-analytics-events"
    Project     = local.pxa_project_name
    Customer    = var.PROJECT_CUSTOMER
    Environment = var.PROJECT_ENV
    Terraform   = true
  }
}
