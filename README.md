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

### Search for suggestions
Search for food and music suggestions given a particular search term,
and an optional limit for number of results.

#### Request
Search requests are GET requests to the `/v1/suggestions/search` endpoint with the
following parameters:

| parameter | data type | description |
|-----------|----------:|-------------|
| `query`   | string    | The term being searched for. This query will be passed along to the Yelp and Spotify APIs without modification. |
| `limit`   | integer   | The maximum number of suggestion results to return (optional). The default is 20, and valid values are anywhere from 1 through 100. |
| `seed`    | string    | Seed data for the randomization of suggestion pairings (optional). This **random seed** can be used to guarantee a specific set of suggestion pairs (Yelp & Spotify APIs permitting). The default value is the value of the `query` parameter. |

#### Response
Search results are JSON documents containing a list of suggestion
hashes, and a canonical URL for the request itself. Each suggestion
hash includes the ID for a specific business from the Yelp API as well
as an ID and type for an item from the Spotify API.

Both IDs are string values, and the type for the music item is one of
`artist`, `album`, `track`.

Wherever possible, the Tunes & Takeout API is written to provide
consistent results for the same queries. This can aid with caching, but
it cannot be guaranteed. Because the Tunes & Takeout API relies upon
the Yelp and Spotify APIs, when their data changes the results of
particular search queries may also change.

#### Examples
##### Simple query without a limit
Request URL:

GET:
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
      "music_type":"artist"
    },
    {
      "food_id":"banana-republic-seattle-5",
      "music_id":"1aDpQ3bo57IlYWmsG5sdlp",
      "music_type":"artist"
    },
    {
      "food_id":"el-gaucho-seattle",
      "music_id":"1J7K2YGisqlwjs9DoJ95td",
      "music_type":"track"
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
      "music_type":"album"
    },
    {
      "food_id":"deli-cut-subs-seattle",
      "music_id":"1W5CDcmIkft5yDfv6pJO9o",
      "music_type":"artist"
    },
    {
      "food_id":"bananas-grill-seattle",
      "music_id":"0L2xg08Uf2oyfTxpOOqxId",
      "music_type":"track"
    }
  ]
}
```

##### Search query with a limit
Request URL:

GET:
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
      "music_type":"track"
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

GET:
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
      "music_type":"track"
    }
  ]
}
```


### Retrieve suggestion
Get the details for a specific suggestion, by ID.

#### Request
This is a GET request which takes no query parameters. The route path
includes the ID of the suggestion:

```
/v1/suggestions/:suggestion_id
```

`:suggestion_id` must be a valid ID returned from this API.

#### Response
If the suggestion ID is valid and found in the API's database, a JSON
document will be returned which includes the suggestion and a canonical
URL for the request itself.

If the suggestion ID is invalid or not found, a response with HTTP
status code 404 will be returned.

#### Examples
##### Valid ID
Request URL:

GET:
```
/v1/suggestions/VzoikPLQUk2WS7xp
```

Response data:

```json
{  
  "href":"https://tunes-takeout-api.herokapp.com/v1/suggestions/VzoikPLQUk2WS7xp",
  "suggestion":{  
    "id":"VzoikPLQUk2WS7xp",
    "food_id":"ohana-seattle-2",
    "music_id":"0BjkSCLEHlcsogSeDim01W",
    "music_type":"track"
  }
}
```

##### Invalid ID
Request URL:

GET:
```
/v1/suggestions/invalid-id-here
```

Response data:
Status code 404 (no data is returned).


### Retrieve top suggestions
Get the IDs for the top suggestions ranked by number of favorites.

#### Request
Top requests are GET requests to the `/v1/suggestions/top` endpoint with the
following parameters:

| parameter | data type | description |
|-----------|----------:|-------------|
| `limit`   | integer   | The maximum number of suggestion IDs to return (optional). The default is 20, and valid values are anywhere from 1 through 100. |

#### Response
A JSON document containing a list of IDs for the top suggestions, ranked
in order of most number of favorites, along with a canonical URL for the
request.

#### Examples
##### Request with default limit
Request URL:

GET:
```
/v1/suggestions/top
```

Response data:

```json
{
  "href":"http://tunes-takeout-api.herokuapp.com/v1/suggestions/top?limit=20",
  "suggestions":[
    "Vzu2NPLQUj_xxnST",
    "Vzu2ffLQUj_xxnVz",
    "Vzu2m_LQUj_xxnba",
    "Vzu2NPLQUj_xxnSd",
    "VzuHJfLQUj_xxnFq",
    "Vzu2zvLQUj_xxnjc",
    "Vzu2m_LQUj_xxnbr",
    "VzuHJfLQUj_xxnFs",
    "VzuHJfLQUj_xxnFt",
    "VzuH-vLQUj_xxnOG",
    "VzuH-vLQUj_xxnOM",
    "VzuHJfLQUj_xxnF0",
    "VzuH-vLQUj_xxnN7",
    "VzuHJfLQUj_xxnFr",
    "Vzu2m_LQUj_xxnbp",
    "VzoxXvLQUmT7dPJ5",
    "Vzu2zvLQUj_xxnjg",
    "Vzu2zvLQUj_xxnjY",
    "Vzu2NPLQUj_xxnSL",
    "VzoxXvLQUmT7dPJ6"
  ]
}
```

##### Request with specified limit
Request URL:

GET:
```
/v1/suggestions/top?limit=3
```

Response data:

```json
{
  "href":"http://tunes-takeout-api.herokuapp.com/v1/suggestions/top?limit=3",
  "suggestions":[
    "Vzu2NPLQUj_xxnST",
    "Vzu2NPLQUj_xxnSd",
    "Vzu2ffLQUj_xxnVz"
  ]
}
```


### Retrieve favorites
Get the list of favorites for a specific user.

#### Request
This is a GET request which takes no query parameters. The route path
includes the ID of the user:

```
/v1/users/:user_id/favorites
```

`:user_id` must be a unique ID, preferably the UID from Spotify's OAuth service.

#### Response
A JSON document will be returned which includes the list of favorited
suggestions and a canonical URL for the request itself.

#### Example
Request URL:

GET:
```
/v1/users/hamled2/favorites
```

Response data:

```json
{
  "href":"https://tunes-takeout-api.herokuapp.com/v1/users/hamled2/favorites",
  "suggestions":[
    "VzoxXvLQUmT7dPJ5",
    "VzoxXvLQUmT7dPJ6"
  ]
}
```


### Add a favorite
Mark the given suggestion as a favorite of a specific user.

#### Request
This is a POST request which takes no query parameters. The route path
includes the ID of the user:

```
/v1/users/:user_id/favorites
```

`:user_id` must be a unique ID, preferably the UID from Spotify's OAuth service.

The POST body must be a JSON document in this form:

```json
{
  "suggestion": "suggestion-id"
}
```

`suggestion-id` must be a valid ID returned from this API.

#### Response
If the request is successful an HTTP 201 status code will be returned,
indicating that the favorite resource was created.

If the request was not successful, the following HTTP status codes may
be returned depending on the specific error:
* 404 - No suggestion with id `suggestion-id` was found.
* 409 - That suggestion is already favorited by that user. 
* 400 - The request was either not a valid JSON document, or did not
  include the `suggestion` key in a hash. 

#### Examples
#### Success
Request URL:

POST:
```
/v1/users/hamled2/favorites
```

Request body:

```json
{
  "suggestion": "VzoxXvLQUmT7dPJ5"
}
```

Response data:
Status code 201 (no data is returned).

#### Invalid Suggestion ID
Request URL:

POST:
```
/v1/users/hamled2/favorites
```

Request body:

```json
{
  "suggestion": "invalid-id-here"
}
```

Response data:
Status code 404 (no data is returned).

#### Bad Request
Request URL:

POST:
```
/v1/users/hamled2/favorites
```

Request body:

```json
{
  "some-other-key": "ignored"
}
```

Response data:
Status code 400 (no data is returned).


### Remove a favorite
Unmark the given suggestion as a favorite of a specific user.

#### Request
This is a DELETE request which takes no query parameters. The route path
includes the ID of the user:

```
/v1/users/:user_id/favorites
```

`:user_id` must be a unique ID, preferably the UID from Spotify's
OAuth service.

The DELETE body must be a JSON document in this form:

```json
{
  "suggestion": "suggestion-id"
}
```

`suggestion-id` must be a valid ID returned from this API.

#### Response
If the request is successful an HTTP 204 status code will be returned,
indicating that the favorite resource was deleted (no content).

If the request was not successful, the following HTTP status codes may
be returned depending on the specific error:
* 404 - No suggestion with id `suggestion-id` was found or the user did
  not have a favorite for that suggestion.
* 400 - The request was either not a valid JSON document, or did not
  include the `suggestion` key in a hash.

#### Examples
#### Success
Request URL:

DELETE:
```
/v1/users/hamled2/favorites
```

Request body:

```json
{
  "suggestion": "VzoxXvLQUmT7dPJ5"
}
```

Response data:
Status code 204 (no data is returned).

#### Invalid Suggestion ID
Request URL:

DELETE:
```
/v1/users/hamled2/favorites
```

Request body:

```json
{
  "suggestion": "invalid-id-here"
}
```

Response data:
Status code 404 (no data is returned).

#### Bad Request
Request URL:

DELETE:
```
/v1/users/hamled2/favorites
```

Request body:

```json
{
  "some-other-key": "ignored"
}
```

Response data:
Status code 400 (no data is returned).


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

GET:
```
/v1/ping
```

Response data:

```json
{
  "data": "pong"
}
```
