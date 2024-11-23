serve-actix-diesel-auth-scaffold
===============================
[![License](https://img.shields.io/badge/license-Apache--2.0%20OR%20MIT%20OR%20CC0--1.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

Server entrypoint scaffold to get you started using actix + diesel with a custom OAuth2 implementation.

Backend implementation to be found at parent repository: https://github.com/SamuelMarks/rust-actix-diesel-auth-scaffold (clone this one directory above to build)

## Why

Honestly everything else is too complicated. When you just want some access tokens and to get started real quick, this is what you need.

Once the server is up—setup/usage notes follow—you can just:
```sh
$ curl -X POST http://localhost:3000/api/token \
       -H 'Content-Type: application/json' \
       -H 'Accept: application/json' \
       -d '{"grant_type": "password", "username": "user", "password": "pass"}'
```

Which—registering user if nonexistent—returns of the form:
```json
{
    "access_token": "user::regular::access_token::4151d642-eb27-4064-b87c-e3d2bfa10435",
    "token_type": "Bearer",
    "expires_in": 3600
}
```

Then you can use this the regular way, for example:

```sh
$ curl http://localhost:3000/secured/secret \
       -H 'Authorization: Bearer user::regular::access_token::4151d642-eb27-4064-b87c-e3d2bfa10435'
```

## Path Table

| Method | Path | Description |
| --- | --- | --- |
| GET | [/api](#getapi) | Versions of this package and its first-party dependencies |
| POST | [/api/token](#postapitoken) | Generate a token for a grant flow.
Implements https://datatracker.ietf.org/doc/html/rfc6749#section-4.1.3 |
| POST | [/secured/logout](#postsecuredlogout) | Logout a user (uses provided Bearer token from Header) |
| GET | [/secured/secret](#getsecuredsecret) | Shows secret to authenticated user (uses provided Bearer token from Header) |

## Reference Table

| Name | Path | Description |
| --- | --- | --- |
| GrantType | [#/components/schemas/GrantType](#componentsschemasgranttype) |  |
| TokenRequest | [#/components/schemas/TokenRequest](#componentsschemastokenrequest) |  |
| password | [#/components/securitySchemes/password](#componentssecurityschemespassword) |  |

## Path Details

***

### [GET]/api

- Summary  
  Versions of this package and its first-party dependencies

#### Responses

***

### [POST]/api/token

- Summary  
  Generate a token for a grant flow.  
  Implements https://datatracker.ietf.org/doc/html/rfc6749#section-4.1.3

#### RequestBody

- application/x-www-form-urlencoded

```json
{
  // optional client ID (as used, for example, in RFC6749's non password non refresh grant flow)
  client_id?: string | null
  // optional client secret (as used, e.g., in RFC6749's non (password|refresh) grant flow)
  client_secret?: string | null
  grant_type: enum[password, authorization_code, client_credentials, refresh_token]
  // optional password (as used, for example, in RFC6749's password grant flow)
  password?: string | null
  // optional refresh token (as used, for example, in RFC6749's refresh grant flow)
  refresh_token?: string | null
  // optional username (as used, for example, in RFC6749's password grant flow)
  username?: string | null
}
```

#### Responses

- 200 Token created

- 400 Unauthorized User

- 404 Not Found User

- 500 Bad Request

***

### [POST]/secured/logout

- Summary  
  Logout a user (uses provided Bearer token from Header)

- Security  
  password

#### Responses

- 200

***

### [GET]/secured/secret

- Summary  
  Shows secret to authenticated user (uses provided Bearer token from Header)

- Security  
  password

#### Responses

- 200 secret endpoint

## References

### #/components/schemas/GrantType

```json
{
  "type": "string",
  "enum": [
    "password",
    "authorization_code",
    "client_credentials",
    "refresh_token"
  ]
}
```

### #/components/schemas/TokenRequest

```ts
{
  // optional client ID (as used, for example, in RFC6749's non password non refresh grant flow)
  client_id?: string | null
  // optional client secret (as used, e.g., in RFC6749's non (password|refresh) grant flow)
  client_secret?: string | null
  grant_type: enum[password, authorization_code, client_credentials, refresh_token]
  // optional password (as used, for example, in RFC6749's password grant flow)
  password?: string | null
  // optional refresh token (as used, for example, in RFC6749's refresh grant flow)
  refresh_token?: string | null
  // optional username (as used, for example, in RFC6749's password grant flow)
  username?: string | null
}
```

### #/components/securitySchemes/password

```json
{
  "type": "oauth2",
  "flows": {
    "password": {
      "tokenUrl": "/api/token",
      "scopes": {}
    }
  }
}
```

## Docker usage

Install Docker, and then run the following, which will make a server available at http://localhost:3000:
```sh
$ docker compose up
````

NOTE: You may need to configure this for your architecture first, for example:
```sh
$ docker compose build --build-arg ARCH_VARIANT='amd64' \
                       --build-arg ARCH='x86_64'
$ docker compose up
```

Or to work with just one image and provide your own database and redis:
```sh
$ docker build -f 'debian.Dockerfile' -t "${PWD##*/}"':latest' .
$ docker run -e DATABASE_URL="$RDBMS_URI" \
             -e REDIS_URL='localhost:6379' \
             -p '3000:3000' \
             --name 'serve_api' \
             "${PWD##*/}"
```

## Native usage

Install Rust, `git`, and ensure you have your PostgreSQL and Redis/Valkey services setup.

### Environment setup

Add an `.env` file or otherwise add these environment variables; replacing connection strings with what you use:

    DATABASE_URL=postgres://rest_user:rest_pass@localhost/rest_db
    REDIS_URL=redis://127.0.0.1/

### Execute

    cargo run

#### `--help`

    Usage: serve-actix-diesel-auth-scaffold [OPTIONS]
    
    Options:
          --hostname <HOSTNAME>  Hostname [env: SADAS_HOSTNAME=] [default: localhost]
      -p, --port <PORT>          Port [env: SADAS_PORT=] [default: 3000]
          --no-host-env          Avoid inheriting host environment variables
          --env-file <ENV_FILE>  Env file, defaults to ".env"
      -e, --env <ENV>            Env var (can be specified multiple times, like `-eFOO=5 -eBAR=can`)
      -h, --help                 Print help
      -V, --version              Print version

## Contribution guide
Ensure all tests are passing [`cargo test`](https://doc.rust-lang.org/cargo/commands/cargo-test.html) and [`rustfmt`](https://github.com/rust-lang/rustfmt) has been run. This can be with [`cargo make`](https://github.com/sagiegurari/cargo-make); installable with:

```sh
$ cargo install --force cargo-make
```

Then run:
```sh
$ cargo make
```

Finally, we recommend [feature-branches](https://martinfowler.com/bliki/FeatureBranch.html) with an accompanying [pull-request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests).
</small>

<hr/>

## License

Licensed under any of:

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or <https://www.apache.org/licenses/LICENSE-2.0>)
- MIT license ([LICENSE-MIT](LICENSE-MIT) or <https://opensource.org/licenses/MIT>)
- CC0 license ([LICENSE-CC0](LICENSE-CC0) or <https://creativecommons.org/publicdomain/zero/1.0/legalcode>)

at your option.

### Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall be
licensed as above, without any additional terms or conditions.
