data "composite_schema" "my_project" {
  schema "public" {
    url = "file://./src/schema.hcl"
  }
  schema "functional" {
    url = "file://./src/functional.sql"
  }
}

docker "postgres" "dev" {
  image  = "postgres:17"
  baseline = <<SQL
   CREATE SCHEMA "auth";
   CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA "auth";
   CREATE TABLE "auth"."users" ("id" uuid NOT NULL DEFAULT auth.uuid_generate_v4(), PRIMARY KEY ("id"));
  SQL
}

env "local" {
  src = data.composite_schema.my_project.url
  url = "postgres://postgres:postgres@localhost:5432/my_database?sslmode=disable"
  dev = docker.postgres.dev.url

  test {
    schema {
      src = ["./tests/schema.test.hcl"]
    }
  }
}
