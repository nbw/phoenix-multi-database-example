# Fly multi-region-databases Phoenix/Elixir Example

Using Fly.io to host a Phoenix web app that’s connected to multiple Postgres read-replica databases (1 read/write master and a number of read-only replicas).

Check out [this blog post](https://nathanwillson.com/blog/posts/2021-09-25-fly-multi-db/) for a detailed explanation.

## Usage

From the `my_app` folder:

```
flyctl launch
```

Note: the above command will create an app and fail the first time. To fix it:
* create a database (refer to blog post)
* set a base secret (refer to fly elixir setup docs)



