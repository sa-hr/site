---
title: Undefined vs. null
date: 2020-06-20
---

This is a very interesting today I learned about JavaScript.

Let’s say you have a function `friendEmail`:

```javascript
class User {
  get friendEmail() {
    const { sharedEmail } = this.data;

    return sharedEmail ? this.data.email : undefined;
  }
}
```

Reviewing this, as I did, you might leave a comment saying:

> Should we return null here instead of undefined?

And you would we wrong! As per TC39 documentation about `null`[^1] you can see the following:

> 4.4.15 null value
>
> primitive value that represents the intentional absence of any object value

So a function that returns a primitive[^2] should in the abstinence of value return an `undefined` and a function that returns an object type should return `null`.

Keep in mind that returning a null wont however be switching return types, since `null` it self is a primitive but it only represents absence of any object value.

Weird stuff, right?

[^1]: https://tc39.es/ecma262/#sec-null-value
[^2]: https://tc39.es/ecma262/#sec-primitive-value
