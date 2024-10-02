data "external_schema" "sqlalchemy" {
  program = [
    "atlas-provider-sqlalchemy",
    "--path", "./orm",
    "--dialect", "postgresql"
  ]
}

data "composite_schema" "my_project" {
  schema "public " {
    url = data.external_schema.sqlalchemy.url
  }
  schema "functional" {
    url = "file://./src/functional.sql"
  }
}

docker "postgres" "dev" {
  image  = "postgres:latest"
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

env "runner" {
  src = data.composite_schema.my_project.url
  url = "postgres://postgres:postgres@my_postgres:5432/my_database?sslmode=disable"
  dev = docker.postgres.dev.url

  test {
    schema {
      src = ["./tests/schema.test.hcl"]
    }
  }
}
