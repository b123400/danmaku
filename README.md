# DanmakuApi

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: http://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix

## Api endpoints

### GET /api/comments

- Params
  - `anilist_id` = integer (e.g. `1`)
  - `source` (only support `kari` now)
  - `filename` or
  - `episode`

- You need to provide either `episide` or `filename`, both of them are string.
- `episode` is prefered over `filename`.
- If `episode` if not given, it will be guessed from `filename`, see `/api/episode/guess`.
- Episode is guessed by system, and can be corrected by user manually later.

Response:
```
{
	"episode_source":"detected", /* or "given" or "user_provided" */
	"episode":"1",
	"comments":[
		{
			"updated_at":"2016-01-01T00:00:00Z",
			"text":"hello",
			"source":"kari",
			"metadata":"{}",
			"inserted_at":"2016-01-01T00:00:00Z",
			"id":4,
			"episode":"1",
			"anilist_id":1
		}
	]
}
```

### GET or POST /api/comments/add

- Params
  - `anilist_id` = integer (e.g. `1`)
  - `source` (only support `kari` now)
  - `text`
  - `metadata` - Can be any string, default is `{}`
  - `filename` or
  - `episode`

- You need to provide either `episide` or `filename`, both of them are string.
- `episode` is prefered over `filename`.
- If `episode` if not given, it will be guessed from `filename`, see `/api/episode/guess`.
- Episode is guessed by system, and can be corrected by user manually later.

Response:
```
{
	"episode_source":"detected", /* or "given" or "user_provided" */
	"episode":"1",
	"comment":{
		"updated_at":"2016-01-01T00:00:00Z",
		"text":"hello",
		"source":"kari",
		"metadata":"{}",
		"inserted_at":"2016-01-01T00:00:00Z",
		"id":4,
		"episode":"1",
		"anilist_id":1
	}
}
```

or

```
{
	"errors": {"field_name": "has error"}
}
```

### GET /api/episodes

### POST /api/episodes

### GET /api/episodes/guess
