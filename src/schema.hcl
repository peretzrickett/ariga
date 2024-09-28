schema "public" {}

table "users" {
    column "id" {
        type = "serial"
        null = false
    }
    column "name" {
        type = "varchar(255)"
        null = false
    }
    column "email" {
        type = "varchar(255)"
        null = false
    }
    column "created_at" {
        type    = "timestamp with time zone"
        null    = false
        default = "now()"
    }
    column "updated_at" {
        type = "timestamp with time zone"
        null = true
    }

    primary_key {
        columns = ["id"]
    }

    index "idx_users_email" {
        unique  = true
        columns = ["email"]
    }

    sql {
        file = "./trigger_updated_at.sql"
    }
}

table "addresses" {
    column "id" {
        type = "serial"
        null = false
    }
    column "street" {
        type = "varchar(255)"
        null = false
    }
    column "city" {
        type = "varchar(255)"
        null = false
    }
    column "user_id" {
        type = "int"
        null = false
    }

    primary_key {
        columns = ["id"]
    }

    foreign_key "fk_user" {
        columns    = ["user_id"]
        references = table.users.column.id
        on_delete  = "CASCADE"
    }

    sql "user_addresses_materialized_view" {
        file = "./mv_addresses.sql"
    }
}
