data "composite_schema" "my_project" {
  schema "public" {
    url = "file:./src/schema.hcl"
  }
  schema "functional" {
    url = "file:./src/functional.sql"
  }
}

env "local" {
  src = data.composite_schema.my_project.url
  url = "postgres://postgres:postgres@localhost:5432/my_database?sslmode=disable"
}
