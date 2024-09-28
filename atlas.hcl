data "composite_schema" "my_schema" {
  schemas = [
    {
      name = "orm_schema"
      url  = "file://./src/orm_schema.sql"
    },
    {
      name = "additional_sql"
      url  = "file://./src/extra.sql"
    },
  ]
}

env "local" {
  url = "postgres://postgres:postgres@localhost:5432/my_database?sslmode=disable"
  src = data.composite_schema.my_schema
}
