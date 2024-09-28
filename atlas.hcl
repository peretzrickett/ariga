data "hcl" "orm_schema" {
  paths = ["./src/orm_model.hcl"]
}

data "sql" "extra_sql" {
  url = "file://./src/extra.sql"
}

env "local" {
  src = [
    data.hcl.orm_schema,
    data.sql.extra_sql,
  ]
  url = "postgres://postgres:postgres@localhost:5432/my_database?sslmode=disable"
}
