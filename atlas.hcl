env "local" {
  src = [
    "file://./src/orm_model.hcl",
    "file://./src/extra.sql",
  ]
  url = "postgres://postgres:postgres@localhost:5432/my_database?sslmode=disable"
}
