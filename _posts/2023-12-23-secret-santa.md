---
title: Secret Santa in Elixir
date: 2023-12-23
---

We've kind of hit a wall with the whole buying presents for each family member thing. Honestly, it's been a real drain on the bank account, and it just doesn't feel right anymore. Every year, it's the same old story – we all end up spending a bunch of money, and half the time, the stuff we buy doesn't get the love we thought it would. You know how it is, after the holidays, you find all these gifts just lying around, barely touched, and it makes you wonder why we even bother.

It feels like we're just buying stuff for the sake of it, and a lot of it ends up being, well, kind of a waste. There's got to be a better way to do this without the whole rigmarole of spending too much and ending up with a bunch of things nobody really needs.

Well, we found a solution in the dark arts of a **Secret Santa**.

## The Requirements

Being crazy about Elixir, the first thing I did was open up Livebook and start implementing a way to create matches.

Here are the requirements:

- It should create pairs.
- It should not match people to themselves.
- It should not match the same pair to each other.

The solution I had in mind was to use a graph DB as you've seen me do on this blog, but I gave up. It was way too hard and everyone was waiting for me to create the pairs.

So here we go:

## My Solution

I am **very sure** I'm not the first one to think of this, but my solution is to first define people with their emails:

```elixir
people = [
  {"Andrei", "andrei@0x7f.dev"},
  {"Person A", "person@example.com"},
  {"Person B", "person+1@example.com"},
  {"Person C", "person+2@example.com"}
]
```

Once you have this array, let's represent it in a different way so you can visualize what I had in mind:

![](/secret_santa/first.png)

The next step would be to create a copy of the list and reverse it:

![](/secret_santa/second.png)

And that kind of works, but what if you had an odd number of people? Like we do...

![](/secret_santa/third.png)

Depending on how you look at it, Person A is not in the best position 🙃.

But what if we just "rotate" the list? What that means is shifting all the elements of a list in a certain direction, wrapping around to the start of the list when you reach the end. In Elixir, this is super simple:

```elixir
def rotate([first | rest] = _list) do
  rest ++ [first]
end
```

Visualizing this would look like this:

![](/secret_santa/forth.png)

While still wrong, we just need to shuffle the starting array. And now the only thing left to do is zip the first and last array so we get pairs.

So in code, this would look like:

```elixir
rotate = fn [first | rest] ->
  rest ++ [first]
end

first = Enum.shuffle(people)
second = rotate.(first)

result = Enum.zip(first, second)
```

With three people, there is a large chance that a mismatch will occur, but when you add more people, it goes down fast. We had seven.

## Extra: Sending Emails

I've discovered [Resend](https://resend.com), and they have a decent Elixir client (not fully compatible with Swoosh), but for scripting things, it's great! I've just added a function that sends the email and ran the script...

```elixir
send_email = fn email, match ->
  client = Resend.client(api_key: System.get_env("LB_RESEND_API_KEY"))

  Resend.Emails.send(client, %{
    from: "Santa <santa@0x7f.dev>",
    to: [email],
    subject: "🎅 You're a Secret Santa!",
    html: "You're buying a gift for <strong>#{match}</strong>! Don't tell anyone 🤫."
  })
end

for {{_, email}, {_name, match}} <- result do
  send_email.(email, match)
end
```

## The End

Have a better algorithm? Send it along; this one has problems which you will discover if you run it for your family 😄.

Thanks to everyone reading for a great past year. I've had fun in the Elixir community and I'm looking forward to the next year.

If you'll be at FOSDEM '24 in Brussels, be sure to say hi! I'll be giving a talk there.
