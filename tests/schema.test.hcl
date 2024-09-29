test "schema" "updated_at_is_null" {

  exec {
    sql = file("populate.sql")
  }

  assert {
    sql = "SELECT (COUNT(*) = 0) FROM public.users WHERE updated_at IS NOT NULL"
    error_message = "updated_at has unexpected non null count"
  }
}

test "schema" "updated_at_updated_by_trigger" {

  exec {
    sql = file("populate.sql")
  }

  exec {
    sql = "UPDATE public.users SET name = 'Alice Smith Updated' WHERE email = 'alice@example.com'"
  }

  assert {
    sql = "SELECT (updated_at IS NOT NULL AND updated_at > created_at) FROM public.users WHERE email = 'alice@example.com'"
    error_message = "updated_at column was not properly updated by trigger"
  }
}

test "schema" "user_addresses_count_as_expected" {

  exec {
    sql = file("populate.sql")
  }

  exec {
    sql = "REFRESH MATERIALIZED VIEW public.user_addresses"
  }

  for_each = [
    {input: "Alice Smith", expected: "2"},
    {input: "Bob Johnson", expected: "1"},
    {input: "Carol Williams", expected: "2"}
  ]

  log {
    message = "Testing ${each.value.input} -> ${each.value.expected}"
  }

  exec {
    sql = "SELECT address_count::TEXT FROM public.user_addresses WHERE name = '${each.value.input}'"
    output = "${each.value.expected}"
  }
}
