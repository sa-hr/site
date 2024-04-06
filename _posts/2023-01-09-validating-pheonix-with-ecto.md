---
title: "Validating Phoenix params with Ecto"
date: 2023-01-09
---

When all you need is a quick way for validation Phoenix params (either query or body) sometimes including a library[^1] is too much, especially for smaller projects. Today I'm going to go thru a very simple way of creating a validation schema, using it in a controller, and rendering the error in the view. None of the ideas in this post are really new[^2] but I didn't find a full write up of this approach.

You can see this in action in my new [Currency API](https://git.0x7f.dev/0x7f/currency) that I developed for fun and for use in my services.

## Creating a schema

While this schema can be in the controller I really like keeping it out, but still in the `_web` project. First we define an Ecto `embedded_schema`[^3]:

```elixir
defmodule RequestValidator do
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field(:currency, :string)
    field(:date, :date)
  end
end
```

This means that our request is going to have two query params: `currency` and `date`. Let's say that only `currency` is required. This is how we would validate it:

```elixir
def validate(params) do
  %RequestValidator{}
  |> cast(params, ~w(currency date)a)
  |> validate_required(~w(currency)a)
end
```

When we run this on a map we will get `%Ecto.Changeset{}` out, which might be enough but I like to provide a standard API for all my validations. If the validation was successful we will return `{:ok, params}` otherwise we want `{:error, errors}`. Only a bit of change is needed to do this:

```elixir
def validate(params) do
  changeset =
    %RequestValidator{}
    |> cast(params, ~w(currency date)a)
    |> validate_required(~w(currency)a)

  case changeset do
    %Ecto.Changeset{valid?: true} ->
      parsed_params =
        changeset
        |> Ecto.Changeset.apply_changes()

      {:ok, parsed_params}

    changeset ->
      {:error, changeset}
  end
end
```

Take a look at the [rate_validator.ex](https://git.0x7f.dev/0x7f/currency/src/branch/master/lib/currency_web/validators/rate_validator.ex) from the project for full details.

## The Controller

So we said we're going to have a route `/info?currency=USD&date=2023-01-01` that we need to validate. Let's use our validator in that route:

```elixir
def info(conn, params) do
  with {:ok, params} <- RequestValidator.validate(params) do
    json(conn, %{msg: :ok})
  end
end
```

If our params are valid this will go thru and respond with `{"msg":"ok"}`. But we need to handle the errors as well. For this we can define an `action_fallback`. Let's call it `FallbackController`. In that new controller we need to define the correct `call/2` definition of the function:

```elixir
def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
  conn
  |> put_status(:bad_request)
  |> put_view(CurrencyWeb.ValidationErrorView)
  |> render("errors.json", %{changeset: changeset})
end
```

All that this does is it checks if the error from our controller is `Ecto.Changeset{}` and if it is it's passing it down to our `ValidationErrorView`. In order to use this controller all you need to do is in your original controller add `action_fallback CurrencyWeb.FallbackController`.

Take a look at the [rate_controller.ex](https://git.0x7f.dev/0x7f/currency/src/branch/master/lib/currency_web/controllers/rate_controller.ex) and [fallback_controller.ex](https://git.0x7f.dev/0x7f/currency/src/branch/master/lib/currency_web/controllers/fallback_controller.ex).

## The View

The final piece of the puzzle is creating our `ValidationErrorView`. To write this we need to traverse the `changeset.errors` array. The shape is simple:

```elixir
{path, {rule, opts}}
```

We have to options, we could use `traverse_errors/2`[^4] from `Ecto.Changeset` or write our own. In order not to import Ecto in my view, I decided to write my own:

```elixir
defp map_schema_errors({path, {rule, _}} = _error) do
  %{
    entry: path,
    rule: rule
  }
end
```

Where usage would be something like: `errors = Enum.map(changeset.errors, &map_schema_errors/1)`, which produces a list of maps that's very easy to render:

```elixir
def render("errors.json", %{changeset: changeset}) do
  errors = Enum.map(changeset.errors, &map_schema_errors/1)

  %{
    error: %{
      type: :validation_failed,
      invalid: errors,
      message: "Validation failed."
    }
  }
end
```

Take a look at [validation_error_view.ex](https://git.0x7f.dev/0x7f/currency/src/branch/master/lib/currency_web/views/validation_error_view.ex) for the full implementation.

And violà, we've introduced a way to validate params (query or otherwise) with something you already have in your project!

## The end

As always I’m open to comments and I would love to hear your thoughts – so please write to me andrei(a)0x7f.dev. Especially if I got something wrong!

---

## Notes

^1: I've used and liked https://hexdocs.pm/tarams/readme.html a lot.

^2: https://dev.to/onpointvn/validate-request-params-in-phoenix-52a7

^3: https://hexdocs.pm/ecto/Ecto.Schema.html but basically just a normal schema that is a map instead of a database record at the end.

^4:
https://hexdocs.pm/ecto/Ecto.Changeset.html#traverse_errors/2
where we would have something like this to produce the same result:

    ```elixir
    changeset
    |> traverse_errors(fn {msg, _opts} ->
      msg
    end)
    |> Map.to_list()
    |> Enum.map(fn {path, [rule]} ->
      %{
        entry: path,
        rule: rule
      }
    end)
    ```

    which I don't think is all that better.
