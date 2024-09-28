env "local" {
  src = "file://./src/schema.hcl"
  url = "postgres://postgres:postgres@localhost:5432/my_database?sslmode=disable"
}
