---
title: Working with promises in batches
date: 2019-12-04
---

We are going to be using typescript for this demonstration since I think it conveys the idea the best. In order to do so we have to define two types used in this example. First one is a function that returns a promise with a type `T`, and the other is an array of arrays of `T` (think 2D matrix).

```typescript
type CurriedPromise<T> = () => Promise<T>;
type ChunkedArray<T> = Array<Array<T>>;
```

First we have a function that returns another function with a promise. We use currying here a) so we can start the promise (e.g. a fetch call) later, and b) since I wanted an easy way to show order of execution.

```typescript
function getData(msg: string): CurriedPromise<string> {
  return () => Promise.resolve(msg);
}
```

Next we store the getters in a array called fifo. That means that we are not going to be popping the items for the array but we are going to be splitting the arrays into chunks. Take note that the type of fifo array is an array of functions that return a string `(() => Promise<string>)[]`.

```typescript
const fifo: Array<CurriedPromise<string>> = [
  getData("1"),
  getData("2"),
  getData("3"),
  getData("4"),
];
```

Let’s say we limit the chunks to two (2) items:

```typescript
const PER_CHUNK = 2;
```

And now we can split the fifo array to contain `PER_CHUNK` (2) items in every array, resulting in an array congaing two arrays with functions. Main part of this function is Math.floor(i / PER_CHUNK). This returns following values for our fifo array for each iteration: `0, 0, 1, 1`. Next up is just creating a chunk array if it doesn’t exists, or adding to it. Note that we create new array with one element already to avoid doing push. Be sure to return the `acc` for every iteration.

```typescript
const chunks = fifo.reduce<ChunkedArray<CurriedPromise<string>>>(
  (acc, curr, i) => {
    const chunkIndex = Math.floor(i / PER_CHUNK);

    if (!acc[chunkIndex]) {
      acc[chunkIndex] = [curr];
    } else {
      acc[chunkIndex].push(curr);
    }

    return acc;
  },
  [],
);
```

Next up is starting all promises in a chunk. We use `Promise.all` here and wait for the result. We also map the every chunk with the instance of the promise. In the end we log for every chunk.

```typescript
(async function doWork() {
  for (const chunk of chunks) {
    const res = await Promise.all(chunk.map((f) => f()));
    console.log(res);
  }
})();
```

This is the result:

```typescript
["1", "2"][("3", "4")];
```
