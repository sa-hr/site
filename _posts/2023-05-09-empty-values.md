---
title: Empty values and Ecto changesets
date: 2023-05-09
---

This week I got a very weird bug report - the API action was not saving an update to the record with a user with limited rights. For this example let's say that this role can only change the `value` of a record and not anything else. Frontend will always send all params of a record but only the value will change.

<!--more-->

## The problem

There are a lot of ways how you can write a helpful checking function, and we had this in our codebase:

```elixir
def value_changed?(document, params) do
  changeset = cast(document, params, ~w(title value)a)
  changed_fields = Map.keys(changeset.changes)

  changed_fields == ~w(value)a or Enum.empty?(changed_fields)
end
```

I found this code to be reasonable and easy to understand, so I quickly wrote a test to prove it must work as I understand it:

```elixir
test "returns true if only value changed" do
  document = %Document{
    title: "",
    value: "Old value"
  }

  params = %{
    "title" => "",
    "value" => "New value"
  }

  assert true == value_changed?(document, params)
end
```

and wouldn't you know it -- failing test! Let's look at the schema for a second, that's our first clue what went wrong!

```elixir
defmodule Document do
  use Ecto.Schema

  schema "documents" do
    field :title, :string
    field :value, :string
  end
end
```

Everything looks good and all right! Let's just check the migration, just in case:

```elixir
def change do
  create table(:documents) do
    add :title, :string
    add :value, :string
  end
end
```

So where is the problem?, I hear you ask. Things might look a bit clearer if we take a look at the `changeset` in our `value_changed?/2`:

```elixir
#Ecto.Changeset<
  action: nil,
  changes: %{title: nil, value: "New value"},
  errors: [],
  data: #Document<>,
  valid?: true
>
```

Hmm that's weird, where is the `title: nil` coming from? That indeed is a change (title was saved as `""`). In order to really understand why Ecto decided to cast our empty string as nil we need to understand the concept of `empty_value`. Here is what docs[^1] say about this:

> Many times, the data given on cast needs to be further pruned, specially regarding empty values. For example, if you are gathering data to be cast from the command line or through an HTML form or any other text-based format, it is likely those means cannot express nil values. For those reasons, changesets include the concept of empty values.

Ah ok so, in short Ecto considers a wide array of things as "empty". And this includes `nil` and `""` for sure. And if we keep reading, it explains the behavior:

> When applying changes using cast/4, an empty value will be automatically converted to the field's default value. If the field is an array type, any empty value inside the array will be removed.

And in our example above the default value is implicitly set to `nil`.

## The fix

There is a couple of ways how we can fix this. The first one would be to just switch the default value of a field to an empty string. Re: this let's not even get how we ended up with an empty string, but suffice it to say it was my fault 🙈.

For sake of having all ways of fixing documented here are the changes we would need to do:

```diff
defmodule Document do
   use Ecto.Schema

   schema "documents" do
-    field :title, :string
+    field :title, :string, default: ""
     field :value, :string
   end
 end
```

Migrating would also be a good idea, but I will leave this with the reader.

BUT! there is a quicker way to fix this issue. Not the _correct_ way, but quick for sure, and one I took.

If you keep reading the docs[^2] for `cast/4` you will find a very interesting option that we can use:

> `:empty_values` - a list of values to be considered as empty when casting. Empty values are always replaced by the default value of the respective field. If the field is an array type, any empty value inside of the array will be removed. To set this option while keeping the current default, use empty_values/1 passing your additional empty values as list

So we can modify our function as following:

```diff
  def value_changed?(document, params) do
-   changeset = cast(document, params, ~w(title value)a)
+   changeset = cast(document, params, ~w(title value)a, empty_values: [nil])
    changed_fields = Map.keys(changeset.changes)

    changed_fields == ~(value)a or Enum.empty?(changed_fields)
  end
```

what this change does in the end is it will only consider `nil` as empty value here. It works in this specific use case (told you it's weird) since we really don't care about other changes than `value`. If this was our `cast` we used for actual mutations I would go ahead and migrate the data instead.

## Why?

Now this is not easy to say. I've looked online and could not find a reason why this is done the way it is, and IMHO I would design the whole concept in a bit of a different approach.

How I would do it is when casting take a look at the default value of the field and only consider this as the empty value in casting. That way you can change the behavior if needed (empty string to nil) and still have the semantic value of `nil` and `""` if you need it.

And as to why this is done this way, my educated guess is to limit the writes to the database. Since if you consider both `nil` and `""` as not a change this will reduce writes to the database while still conveying the same message - the field is empty.

Can you think of a better reason, or a better way of fixing this? Do let me know and I'll write up a follow up.

[^1]: https://hexdocs.pm/ecto/3.10.1/Ecto.Changeset.html#module-empty-values
[^2]: https://hexdocs.pm/ecto/3.10.1/Ecto.Changeset.html#cast/4
