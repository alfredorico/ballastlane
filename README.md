# Ballastlane

A full-stack Pokemon application with a Rails 8.1 API backend and React 19 frontend.

## Tech Stack

| Layer    | Technology                         |
| -------- | ---------------------------------- |
| Backend  | Ruby 3.4.5, Rails 8.1.1 (API-only) |
| Frontend | React 19, Vite 7, Tailwind CSS 4   |
| Database | PostgreSQL 15+                     |
| DevOps   | Docker, Docker Compose             |

## Project Structure

```
ballastlane/
├── ballastlane-api/           # Rails API backend
├── ballastlane-web-react/     # React frontend
├── docker-compose.yml         # Multi-container orchestration
└── makefile                   # Development commands
```

## Requirements

- Docker & Docker Compose

## Quick Start with Docker

```bash
# Full setup (build, install dependencies, run migrations)
make setup

# Seed the database (creates admin user)
make rails db:seed

# Start all services
make up
```

The application will be available at:

- **Frontend:** http://localhost:5173
- **API:** http://localhost:3000

### Default Credentials

- Username: `admin`
- Password: `admin`

## Makefile Commands

| Command              | Description                            |
| -------------------- | -------------------------------------- |
| `make up`            | Start all Docker services              |
| `make down`          | Stop all Docker services               |
| `make restart`       | Restart all Docker services            |
| `make setup`         | Full project setup (build + migrate)   |
| `make bundle [args]` | Run bundler commands in API container  |
| `make rails [args]`  | Run Rails commands in API container    |
| `make console`       | Open Rails console                     |
| `make test`          | Run Rails unit tests                   |
| `make rspec [args]`  | Run RSpec tests with arguments         |
| `make migrate`       | Run database migrations                |
| `make shell`         | Open bash shell in API container       |
| `make pg`            | Connect to PostgreSQL database         |
| `make npm [args]`    | Run npm commands in frontend container |

## Key Libraries

### Backend (Rails API)

| Gem               | Purpose                                |
| ----------------- | -------------------------------------- |
| `pg`              | PostgreSQL database adapter            |
| `puma`            | Web server                             |
| `bcrypt`          | Password hashing (has_secure_password) |
| `jwt`             | JWT token generation/verification      |
| `rack-cors`       | CORS support for cross-origin requests |
| `poke-api-v2`     | PokeAPI wrapper                        |
| `rspec-rails`     | Testing framework                      |
| `factory_bot`     | Test data factories                    |
| `vcr` + `webmock` | HTTP request mocking for tests         |

### Frontend (React)

| Package            | Purpose                     |
| ------------------ | --------------------------- |
| `react`            | UI library (v19)            |
| `react-dom`        | React DOM rendering         |
| `react-router-dom` | Client-side routing (v7)    |
| `tailwindcss`      | Utility-first CSS framework |
| `vite`             | Build tool and dev server   |
| `eslint`           | Code linting                |

## Authentication

### Overview

This API uses JWT with a dual-token system:

| Token Type    | Expiration | Purpose                   |
| ------------- | ---------- | ------------------------- |
| Access Token  | 15 minutes | Authenticate API requests |
| Refresh Token | 1 week     | Obtain new token pairs    |

### Security Features

- **Token Rotation**: Each refresh generates new access AND refresh tokens
- **Single Session**: Logging in invalidates tokens on other devices
- **JTI Revocation**: Tokens are invalidated when user's JTI changes

### Endpoints

#### POST /api/v1/auth/signup

Create a new user account.

**Request:**

```json
{
  "username": "johndoe",
  "password": "mypassword123",
  "password_confirmation": "mypassword123"
}
```

**Validations:**

- Username: alphanumeric only, whitespace auto-trimmed
- Password: 5-64 characters, alphanumeric + special chars (. - ! \* #)

**Response (201 Created):**

```json
{
  "message": "Account created successfully",
  "user": {
    "id": 1,
    "username": "johndoe",
    "created_at": "2025-01-15T10:30:00Z"
  },
  "access_token": "eyJhbGciOiJIUzI1NiJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiJ9...",
  "token_type": "Bearer",
  "expires_in": 900
}
```

#### POST /api/v1/auth/login

Authenticate and obtain tokens.

**Request:**

```json
{
  "username": "johndoe",
  "password": "mypassword123"
}
```

**Response (200 OK):**

```json
{
  "message": "Login successful",
  "user": {
    "id": 1,
    "username": "johndoe",
    "created_at": "2025-01-15T10:30:00Z"
  },
  "access_token": "eyJhbGciOiJIUzI1NiJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiJ9...",
  "token_type": "Bearer",
  "expires_in": 900
}
```

#### DELETE /api/v1/auth/logout

Revoke the current session (requires authentication).

**Headers:**

```
Authorization: Bearer <access_token>
```

**Response (200 OK):**

```json
{
  "message": "Logged out successfully"
}
```

#### POST /api/v1/auth/refresh_token

Exchange refresh token for new token pair.

**Request:**

```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiJ9..."
}
```

**Response (200 OK):**

```json
{
  "message": "Token refreshed successfully",
  "access_token": "eyJhbGciOiJIUzI1NiJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiJ9...",
  "token_type": "Bearer",
  "expires_in": 900
}
```

### Error Responses

**401 Unauthorized:**

```json
{
  "error": "Invalid username or password"
}
```

**422 Unprocessable Entity:**

```json
{
  "error": "Signup failed",
  "details": [
    "Username must contain only alphanumeric characters",
    "Password is too short (minimum is 5 characters)"
  ]
}
```

## API Usage Examples (cURL)

```bash
# Set base URL
BASE_URL="http://localhost:3000/api/v1"

# Signup
curl -X POST "$BASE_URL/auth/signup" \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "test123", "password_confirmation": "test123"}'

# Login
curl -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin"}'

# Store tokens (after login, replace with actual tokens)
ACCESS_TOKEN="your_access_token_here"
REFRESH_TOKEN="your_refresh_token_here"

# Refresh tokens
curl -X POST "$BASE_URL/auth/refresh_token" \
  -H "Content-Type: application/json" \
  -d "{\"refresh_token\": \"$REFRESH_TOKEN\"}"

# Logout
curl -X DELETE "$BASE_URL/auth/logout" \
  -H "Authorization: Bearer $ACCESS_TOKEN"
```

## Pokemon API

Protected endpoints for fetching Pokemon data from PokeAPI.

### Endpoints

#### GET /api/v1/pokemons

List Pokemon with pagination. Returns basic info (id, name, photo).

**Headers:**

```
Authorization: Bearer <access_token>
```

**Query Parameters:**
| Parameter | Default | Description |
|-----------|---------|-------------|
| page | 1 | Page number |
| per_page | 20 | Items per page |

**Response (200 OK):**

```json
{
  "pokemons": [
    {
      "id": 1,
      "name": "bulbasaur",
      "photo": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png"
    },
    {
      "id": 2,
      "name": "ivysaur",
      "photo": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/2.png"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 1302,
    "total_pages": 66,
    "next_page": 2,
    "previous_page": null
  }
}
```

#### GET /api/v1/pokemons/:id

Get detailed Pokemon information by ID or name.

**Headers:**

```
Authorization: Bearer <access_token>
```

**Response (200 OK):**

```json
{
  "id": 25,
  "name": "pikachu",
  "weight": 6.0,
  "height": 0.4,
  "types": ["electric"],
  "abilities": ["static", "lightning-rod"],
  "photo": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png",
  "description": "When several of these POKéMON gather, their electricity could build and cause lightning storms."
}
```

**Error Response (404 Not Found):**

```json
{
  "error": "Pokemon not found"
}
```

### Pokemon API Usage Examples (cURL)

```bash
# Set base URL and access token (obtain token via login first)
BASE_URL="http://localhost:3000/api/v1"
ACCESS_TOKEN="your_access_token_here"

# List Pokemon (first page, 20 items)
curl -X GET "$BASE_URL/pokemons" \
  -H "Authorization: Bearer $ACCESS_TOKEN"

# List Pokemon with pagination
curl -X GET "$BASE_URL/pokemons?page=2&per_page=10" \
  -H "Authorization: Bearer $ACCESS_TOKEN"

# Get Pokemon by ID
curl -X GET "$BASE_URL/pokemons/25" \
  -H "Authorization: Bearer $ACCESS_TOKEN"

# Get Pokemon by name
curl -X GET "$BASE_URL/pokemons/pikachu" \
  -H "Authorization: Bearer $ACCESS_TOKEN"

# Full workflow: Login and fetch Pokemon
ACCESS_TOKEN=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin"}' | jq -r '.access_token')

curl -X GET "$BASE_URL/pokemons/charmander" \
  -H "Authorization: Bearer $ACCESS_TOKEN"
```

## Generative AI Tools

In regards to this requested task, the requirements are kinda general that makes room for some assumptions. In that sense,
I've created a prompt in this [Claude Chat](https://claude.ai/share/f9dc8404-0c21-45ba-b059-b7c6831d3331).

The prompt is:

```
Hey Claude,

I need to build a Task management API in Rails 7.1 with PostgreSQL. I need a Task resource with CRUD operations.

Following are my specific requirements on each paragraph:

The Task model contains the following attributes:
- title (string, required, max 200 chars). Apply trimming of the field in a before_save callback.
- description (text, optional).
- status (enum with values: pending, in_progress, completed). Let's define `pending` as default using the `attribute` method with default: 'pending' and prefix `status_` to avoid possible method collisions.
- due_date (datetime). Let's add a validation that this field can not be less than the current timestamp.
- user_id that refers to an existent User model (no need to generate it). Let's add an index and foreign key constraint in the database using a rails migration. Let's add relations has_many/belongs_to on Task/User models respectively with `dependent: :destroy` on User model.

Let's create an RSpec test for the Task model to test validations and relations

Let's implement an authentication system using JWT (don't use Devise) and providing short-live access token with refresh tokens. The authentication controller should provide, signup, login and logout endpoints. Let's also add versioning to the endpoints '/api/v1'

For the TasksController:
- Let's add versioning to the endpoints '/api/v1'
- Let's use strong parameters, proper status HTTP codes for responses, and structured error responses.
- Let's create a TaskSerializer using jsonapi-serializer gem for the JSON response
- Let's protect TaskControllers endpoints with authentication. So provide this protection in the ApplicationController to be inherited in controllers.
- Lets generate a RSpec test of type request to test the CRUD operations. Let's provide tests to validate the access with authenticated and non-authenticated users

Please, don't try to install any project on my local. Just provide the files needed in a logical order and any observations you may have.

Let me know any further clarification you might need if you consider it.
```

My strategy for prompt creation is to provide good enough context and to be as specific as possible based on my criteria.

Honestly, Claude is really accurate. It provided even more things that I didn't specify (eg. CORS configuration).

There are some missing things that AI didn't requested for clarification:

- Handling invalid json data on POST request that would trigger HTTP 500 instead of 422. Actually I didn't consider it for the Pokemon app (ugh!!)
- Soft deletion? (audit trails)
- Pagination?

But in the end, AI is a powerful tool to provide a good starting point that now days works really really well, helping developers to be faster and happy!

In this repo there is a file.zip generated by Claude with its solution.
