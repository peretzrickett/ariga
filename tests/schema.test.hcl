test "shema" "populate_data" {

  exec {
    sql = <<<SQL
-- Insert sample users
INSERT INTO public.users (name, email, created_at)
VALUES
("Alice Smith", "alice@example.com", now()),
("Bob Johnson", "bob@example.com", now()),
("Carol Williams", "carol@example.com", now())

-- Insert sample addresses
INSERT INTO public.addresses (street, city, user_id)
VALUES
("123 Maple Street", "Springfield", (SELECT id FROM public.users WHERE email = "alice@example.com")),
("456 Oak Avenue", "Springfield", (SELECT id FROM public.users WHERE email = "alice@example.com")),
("789 Pine Road", "Shelbyville", (SELECT id FROM public.users WHERE email = "bob@example.com")),
("101 Elm Street", "Ogdenville", (SELECT id FROM public.users WHERE email = "carol@example.com")),
("202 Birch Boulevard", "Ogdenville", (SELECT id FROM public.users WHERE email = "carol@example.com"))
SQL
  }

  log {
    message = "Populated database with test data"
  }
}

test "schema" "updated_at_is_null" {

  exec {
    sql = <<< SQL
SELECT COUNT(*) AS not_null_count
FROM public.users
WHERE updated_at IS NOT NULL
SQL

    format = table

    output = <<<RESULT
not_null_count
--------------
0
RESULT
  }
}

test "schema" "updated_at_updated_by_trigger" {

  exec {
    sql = <<<SQL
UPDATE public.users
SET name = "Alice Smith Updated"
WHERE email = "alice@example.com"
SQL
  }

  assert {
    sql = <<<RESULT
(SELECT
    (updated_at IS NOT NULL AND updated_at > created_at)
FROM public.users
WHERE email = "alice@example.com") = true
RESULT
    error = "updated_at column was not properly updated by trigger"
  }
}

test "schema" "user_addresses_count_as_expected" {

  exec {
    sql = "REFRESH MATERIALIZED VIEW public.user_addresses"
  }

  exec {
    sql = <<<SQL
SELECT email, address_count
FROM public.user_addresses
ORDER BY email
SQL
    format = table
    output = <<<RESULT
email             | address_count
------------------+--------------
alice@example.com | 2
bob@example.com   | 1
carol@example.com | 2
RESULT
  }
}
