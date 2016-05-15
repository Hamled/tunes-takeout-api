# Tunes & Takeout API
The Tunes & Takeout API allows programmatic access to randomized
suggestions of specific food and music pairings, that data for which
is obtained from the
[Yelp](https://www.yelp.com/developers/documentation/v2/overview) and
[Spotify](https://developer.spotify.com/web-api/) APIs.

The API endpoint is available at
https://tunes-takeout-api.herokuapp.com/ and all paths listed in this
documentation should be assumed to use that base URL.

## API Specification
This is version 1 of the Tunes & Takeout API. To ensure consistency if
the API evolves further, all requests to version 1 are prefixed with
the path `/v1/`.

### Search
Search for food and music suggestions given a particular search term,
and an optional limit for number of results.

#### Request
Search requests are GET requests to the `/v1/search` endpoint with the
following parameters:

| parameter | data type | description |
|-----------|----------:|-------------|
| `query`   | string    | The term being searched for. This query will be passed along to the Yelp and Spotify APIs without modification. |
| `limit`   | integer   | The maximum number of suggestion results to return (optional). The default is 10, and valid values are anywhere from 1 through 100. |
| `seed`    | string    | Seed data for the randomization of suggestion pairings (optional). This **random seed** can be used to guarantee a specific set of suggestion pairs (Yelp & Spotify APIs permitting). The default value is the value of the `query` parameter. |

#### Response
Search results are JSON documents containing a list of suggestion
hashes, and the canonical URL for the request itself. Each suggestion
hash includes the ID for a specific business from the Yelp API as well
as an ID and type for an item from the Spotify API.

Both IDs are string values, and the type for the music item is one of
`artist`, `album`, `track`, or `playlist`.

Wherever possible, the Tunes & Takeout API is written to provide
consistent results for the same queries. This can aid with caching, but
it cannot be guaranteed. Because the Tunes & Takeout API relies upon
the Yelp and Spotify APIs, when their data changes the results of
particular search queries may also change.

#### Examples
##### Simple query without a limit
Request URL:

```
/v1/search?query=pie
```

Response data:

```
{
  "href": "https://tunes-takeout-api.herokuapp.com/v1/search?query=pie&limit=10&seed=pie",
  "suggestions": [
    {
      "food_id": "TBD",
      "music_id": "TBD"
      "music_type": "track",
    },
    {
      "food_id": "TBD",
      "music_id": "TBD"
      "music_type": "album",
    },
    {
      "food_id": "TBD",
      "music_id": "TBD"
      "music_type": "track",
    },
    {
      "food_id": "TBD",
      "music_id": "TBD"
      "music_type": "artist",
    },
    {
      "food_id": "TBD",
      "music_id": "TBD"
      "music_type": "artist",
    },
    {
      "food_id": "TBD",
      "music_id": "TBD"
      "music_type": "album",
    },
    {
      "food_id": "TBD",
      "music_id": "TBD"
      "music_type": "track",
    },
    {
      "food_id": "TBD",
      "music_id": "TBD"
      "music_type": "album",
    },
    {
      "food_id": "TBD",
      "music_id": "TBD"
      "music_type": "track",
    },
    {
      "food_id": "TBD",
      "music_id": "TBD"
      "music_type": "track",
    }
  ]
}
```

##### Search query with a limit
Request URL:

```
/v1/search?query=avocado&limit=3
```

Response data:

```
{
  "href": "https://tunes-takeout-api.herokuapp.com/v1/search?query=avocado&limit=3&seed=avocado",
  "suggestions": [
    {
      "food_id": "TBD",
      "music_id": "TBD"
      "music_type": "album",
    },
    {
      "food_id": "TBD",
      "music_id": "TBD"
      "music_type": "artist",
    },
    {
      "food_id": "TBD",
      "music_id": "TBD"
      "music_type": "track",
    }
  ]
}
```

##### Search query with a random seed
Request URL:

```
/v1/search?query=avocado&limit=3&seed=12345
```

Response data:

```
{
  "href": "https://tunes-takeout-api.herokuapp.com/v1/search?query=avocado&limit=3&seed=12345",
  "suggestions": [
    {
      "food_id": "TBD",
      "music_id": "TBD"
      "music_type": "track",
    },
    {
      "food_id": "TBD",
      "music_id": "TBD"
      "music_type": "album",
    },
    {
      "food_id": "TBD",
      "music_id": "TBD"
      "music_type": "artist",
    }
  ]
}
```
