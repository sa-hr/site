---
title: "Unit testing SQL functions in an Elixir project"
date: 2023-06-02
---

If you ever needed to add an SQL function that you can use in your Elixir project you might have skipped writing tests for it. There are a couple of official ways[^1] [^2] you can write unit tests for PostgreSQL functions but having it in the same code base will make it so you actually maintain the tests.

## Creating a function

First of all let's write an SQL function. Here is one I wrote a few days ago, converting a string representation of a number to either the decimal type or `NULL`.

```sql
CREATE OR REPLACE FUNCTION try_convert_to_decimal (v_input text)
  RETURNS DECIMAL
  AS $$
DECLARE
  v_dec_value DECIMAL DEFAULT NULL;
BEGIN
  BEGIN
    v_dec_value := v_input::decimal;
  EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
  END;
  RETURN v_dec_value;
END;
$$
LANGUAGE plpgsql;
```

Easiest way of getting this into your Postgres database is by using a migration. You can find it in my example project[^3]. To create it just run:

```bash
$ mix ecto.gen.migrate add_function
```

In code you might be using this like:

```elixir
from(
  ud in UserData,
  where: fragment("try_convert_to_decimal (?) >= ?", ud.value, ^some_value)
)
```

## Testing

Testing this is very easy actually. And we can accomplish this by running raw SQL queries against our database by using Ecto[^4]. Here is the function that we will use in order to run our query:

```elixir
def run_query(query) do
  Ecto.Adapters.SQL.query(TestingSqlFunctions.Repo, query, [])
end
```

This returns a `Postgrex.Result` struct that we can assert on:

```elixir
%Postgrex.Result{
  columns: ["result"],
  command: :select,
  connection_id: 4618,
  num_rows: 1,
  rows: [[Decimal.new("100")]]
}
```

And so, a full test will look something like this[^5]:

```elixir
test "converts a string integer to decimal" do
  query = "SELECT try_convert_to_decimal ('100') AS result;"
  result = Decimal.new("100")

  assert {:ok,
          %{
            columns: ["result"],
            rows: [[^result]]
          }} = run_query(query)
end
```

That's it! Now you won't have random changes or dropped migrations breaking your app 🎉! Do you have any better ideas on how to handle this? [Reach out](mailto:andrei@0xf.dev) and together we can extend this post.

[^1]: https://pgtap.org/
[^2]: https://github.com/postgrespro/testgres
[^3]: https://git.0x7f.dev/andreicek/testing_sql_functions/src/branch/master/priv/repo/migrations/20230602112518_add_function.exs
[^4]: https://www.amberbit.com/blog/2018/6/12/executing_raw_sql_queries_in_elixir/
[^5]: https://git.0x7f.dev/andreicek/testing_sql_functions/src/branch/master/test/testing_sql_functions_test.exs
