# Ballastlane API

Rails 8.1 API-only application with JWT authentication.

## Requirements

- Ruby 3.4.5
- Rails 8.1.1
- PostgreSQL 15+
- Docker & Docker Compose

## Setup

### Using Docker (Recommended)

```bash
# Start services
make up

# Install dependencies
make bundle install

# Run migrations
make migrate

# Seed the database (creates admin user)
make rails db:seed
```

### Default Credentials

- Username: `admin`
- Password: `admin`

## Authentication

### Overview

This API uses JWT (JSON Web Token) for authentication with a dual-token system:

| Token Type | Expiration | Purpose |
|------------|------------|---------|
| Access Token | 15 minutes | Authenticate API requests |
| Refresh Token | 1 week | Obtain new token pairs |

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
- Password: 5-64 characters, alphanumeric + special chars (. - ! * #)

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
    { "id": 1, "name": "bulbasaur", "photo": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png" },
    { "id": 2, "name": "ivysaur", "photo": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/2.png" }
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
  "hq_photo": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png",
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
