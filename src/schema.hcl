schema "public" {}

table "users" {
    schema = schema.public
    column "id" {
        type = serial
        null = false
    }
    column "name" {
        type = varchar(255)
        null = false
    }
    column "email" {
        type = varchar(255)
        null = false
    }
    column "created_at" {
        type    = timestamptz()
        null    = false
        default = sql("now()")
    }
    column "updated_at" {
        type = timestamptz()
        null = true
    }

    primary_key {
        columns = [column.id]
    }

    index "idx_users_email" {
        unique  = true
        columns = [column.email]
    }
}

table "addresses" {
    schema = schema.public
    column "id" {
        type = serial
        null = false
    }
    column "street" {
        type = varchar(255)
        null = false
    }
    column "city" {
        type = varchar(255)
        null = false
    }
    column "user_id" {
        type = int
        null = false
    }

    primary_key {
        columns = [column.id]
    }

    foreign_key "fk_user" {
        columns     = [column.user_id]
        ref_columns = [table.users.column.id]
        on_delete   = CASCADE
        on_update   = CASCADE
    }
}
