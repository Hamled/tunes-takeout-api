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

### Suggestion Search
Search for food and music suggestions given a particular search term,
and an optional limit for number of results.

#### Request
Search requests are GET requests to the `/v1/suggestions/search` endpoint with the
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
/v1/suggestions/search?query=banana
```

Response data:

```json
{
  "href":"https://tunes-takeout-api.herokuapp.com/v1/suggestions/search?query=banana&limit=10&seed=banana",
  "suggestions":[
    {
      "food_id":"banana-republic-bellevue",
      "music_id":"0vD0IZ6ol5V30tWQRQKEb5",
      "music_type":"album"
    },
    {
      "food_id":"banana-republic-seattle-2",
      "music_id":"1WGWUsR3u4DpQEaE8zWwcr",
      "music_type":"artist"
    },
    {
      "food_id":"cocoa-banana-seattle",
      "music_id":"13onf2qabc56lH8p8y9CpO",
      "music_type":"playlist"
    },
    {
      "food_id":"banana-republic-seattle-5",
      "music_id":"1aDpQ3bo57IlYWmsG5sdlp",
      "music_type":"artist"
    },
    {
      "food_id":"el-gaucho-seattle",
      "music_id":"1J7K2YGisqlwjs9DoJ95td",
      "music_type":"playlist"
    },
    {
      "food_id":"metropolitan-grill-seattle",
      "music_id":"0S2x4SuAe2Yp2N8I7SxQpA",
      "music_type":"artist"
    },
    {
      "food_id":"montana-banana-seattle",
      "music_id":"1Lm9GiMyMtnjhvE4xmK07f",
      "music_type":"album"
    },
    {
      "food_id":"top-banana-seattle",
      "music_id":"1DU10W5hGXHt5qhY7nHSMw",
      "music_type":"playlist"
    },
    {
      "food_id":"deli-cut-subs-seattle",
      "music_id":"1W5CDcmIkft5yDfv6pJO9o",
      "music_type":"playlist"
    },
    {
      "food_id":"bananas-grill-seattle",
      "music_id":"0L2xg08Uf2oyfTxpOOqxId",
      "music_type":"playlist"
    }
  ]
}
```

##### Search query with a limit
Request URL:

```
/v1/suggestions/search?query=avocado&limit=3
```

Response data:

```json
{
  "href":"https://tunes-takeout-api.herokuapp.com/v1/suggestions/search?query=avocado&limit=3&seed=avocado",
  "suggestions":[
    {
      "food_id":"avocados-mexican-restaurant-everett",
      "music_id":"0r2HEDK9STwKSmzmeJiAle",
      "music_type":"artist"
    },
    {
      "food_id":"saleys-classic-seattle",
      "music_id":"0s2PZZynA0W2Z8iHnRZS48",
      "music_type":"playlist"
    },
    {
      "food_id":"homegrown-seattle-4",
      "music_id":"1Bg7byH7AeQhvwfXs4iRiG",
      "music_type":"album"
    }
  ]
}
```

##### Search query with a random seed
Request URL:

```
/v1/suggestions/search?query=avocado&limit=3&seed=12345
```

Response data:

```json
{
  "href":"https://tunes-takeout-api.herokuapp.com/v1/suggestions/search?query=avocado&limit=3&seed=12345",
  "suggestions":[
    {
      "food_id":"saleys-classic-seattle",
      "music_id":"1Bg7byH7AeQhvwfXs4iRiG",
      "music_type":"album"
    },
    {
      "food_id":"homegrown-seattle-4",
      "music_id":"0r2HEDK9STwKSmzmeJiAle",
      "music_type":"artist"
    },
    {
      "food_id":"avocados-mexican-restaurant-everett",
      "music_id":"0s2PZZynA0W2Z8iHnRZS48",
      "music_type":"playlist"
    }
  ]
}
```


### Ping
Test availability of the API.

#### Request
The `ping` request takes no parameters, and it exists primarily to allow
applications to programmatically determine if the Tunes & Takeout API is
currently available (can be reached by the client application).

#### Response
The response to `ping` is always the same. If the API is available an
HTTP 200 status code will be returned, otherwise a timeout or other
status code will be returned.

#### Example
Request URL:

```
/v1/ping
```

Response data:

```json
{
  "data": "pong"
}
```
