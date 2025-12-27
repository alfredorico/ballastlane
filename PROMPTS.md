# Project Prompts

This file documents the prompts used during the development of this project.

## Initial Setup

### Prompt 1: Project Introduction

```
Project Ballastlane

Hey Claude. I've started this new project to demonstrate my skills as a software engineer.
I'll provide requirements during the development process with initial ideas
from my experience in order to get feedback and work together.

I've created an initial dockerized backend api, please take a look at this project to get familiar.
```

### Prompt 2: Initial Commit

```
Please, lets create the first commit using conventional commit message as dictated by https://www.conventionalcommits.org/en/v1.0.0/. I'll review your commit message.
```

## Authentication

### Prompt 3: JWT Authentication Implementation

```
Alright now let's implement a simple auth mechanism with jwt for the rails api. Lets avoid to use the devise gem for this solution, the jwt gem should be enough.

The requirements are:

For the auth API:

- Lets create a versioned AuthController considering the path '/api/v1' with endpoints for signup, login, logout, and refresh_token (in order to have better user experience).

- For the refresh token strategy lets consider the following: Refresh token expiration in 1 week (long live token) and access token expiration of 15 minutes expiration. For security purpose let's generate a new Access Token and a new Refresh Token when a request for refresh has been made.

In that sense, let's create a versioned auth controller for the features above considering the path '/api/v1/'.

For the auth data model:

- Lets create a simple active record User model with `username` and `password` fields. username should be only alpha numeric so lets provide validations for it. Lets provide automatic left/right trimming for the field. For the password lets validate the password with a length range of 5 to 64 characters, and also allow only alphanumeric and optionally (if they exists) the special characters . - ! \* #

- Lets consider to use a JTI revocation strategy in the same user model because we need a simple approach and we don't want multi-device access.

- Please add a seed file for an initial user creation with credentials: user: admin, password: admin.

- Lets create a README.file (in the root folder ) providing a section about the authentication process in the backend describing the endpoints available and curl commands to interact with them.

Let me know any further clarification you may need for execute this plan.
```

## Testing

### Prompt 4: RSpec Testing Implementation

```
Lets implement testing for the features built so far.

Please provide an RSpec file for the User model to test its behavior

For the AuthController, lets create an RSpec of type `request`. Lets define contexts for each endpoint considering successful and failure cases. Remember to consider a failure case for invalid signup or login data

For the refresh token endpoint it's important to also test behavior when trying to refresh with expired tokens either `refresh` (long live) or `access` (short live) tokens.
```

## Pokemon API Integration

### Prompt 5: Pokemon API Gem Exploration

Research the poke-api-v2 gem (https://github.com/rdavid1099/poke-api-v2) to understand how to retrieve Pokemon data.

```
Can you tell me how could I get the following attributes for a given pokemon?
- weight
- height
- a list of types name
- a list of abilities name
- a photo of the pokemon
- a description of the pokemon
```

**Findings:** The gem wraps PokéAPI v2 using `PokeApi.get()`. Pokemon attributes (weight, height, types, abilities, sprites) come from the `pokemon` endpoint, while descriptions require a separate call to `pokemon_species` for `flavor_text_entries`.

```ruby
require 'poke-api-v2'

pokemon_name = 'pikachu'

# Get Pokémon data
pokemon = PokeApi.get(pokemon: pokemon_name)

# Extract all attributes
data = {
  weight: pokemon.weight / 10.0,  # Convert to kg
  height: pokemon.height / 10.0,  # Convert to meters
  types: pokemon.types.map { |t| t.type.name },
  abilities: pokemon.abilities.map { |a| a.ability.name },
  photo: pokemon.sprites.front_default,
  hq_photo: pokemon.sprites.other.official_artwork.front_default
}

# Get description (requires chaining to species)
species = pokemon.species.get
data[:description] = species.flavor_text_entries
  .find { |entry| entry.language.name == 'en' }
  &.flavor_text
  &.gsub("\n", " ")  # Clean up formatting

puts data
```

### Prompt 6: Pokemon API Clean Architecture Implementation

```
Lets start to work with the following plan considering that we have the gem 'poke-api-v2' installed in the system.

I need to build a PokemonController to provide the following protected endpoints by authentication:

- '/api/v1/pokemons' to list all pokemons
- '/api/v1/pokemons/:id' to fetch a specific pokemon.

I'd like to implement a clean architecture approach according to the following criteria:

- Create a domain entity called Entities::Pokemon to wrap specific pokemon data fetched from the api.
- Create a PokemonApiAdapter with the methods:
  1. find: in order to find pokemon giving and id. You can use the following ruby snippet just as a guidance of the data that I need per pokemon. You need to create proper private methods for the extraction
  2. all: receiving a limit (default to 20) and offset (default to 0)

- Create a PokemonRepository class receiving an adpater instance of PokemonApiAdapter as default to follow the clean architecture pattern. It should define the find and all methods as wrappers
- Create a Pokemon::FetchService to get data for a specific pokemon giving its id
- Create a Pokemon::ListService to fetch a list of pokemon considering the pagination info provided by the call to `PokeApi.get(:pokemon)`. Let's use a default of 20 records per page.
- Create a ValueObjects::ServiceResult to hold successful or error status with data. This class should be used in the services class Pokemon::FetchService and Pokemon::ListService
- Finally create a controller Api::V1::PokemonsController defining the following protected endpoints (user must be authenticated) that internally use the propose service classes:
  GET /api/v1/pokemons (We need to provide paginated data)
  GET /api/v1/pokemons/:id

So the files would be:

Domain Entities
app/entities/pokemon.rb

Value Objects:
app/value_objects/service_result.rb

External API Integration
app/adapters/pokemon_api_adapter.rb

Repositories for Data Access Layer
app/repositories/pokemon_repository.rb

Services for business logic:
app/services/pokemon/fetch_service.rb
app/services/pokemon/list_service.rb

Controllers
app/controllers/api/v1/pokemons_controller.rb
```

**Architecture:**
```
Controller → Service → Repository → Adapter → PokeAPI
                ↓
          ServiceResult (success/error)
                ↓
          Entities::Pokemon
```

**Key Decisions:**
- List endpoint returns basic info only (id, name, photo) for performance
- Show endpoint returns full details (weight, height, types, abilities, photo, hq_photo, description)
- Errors handled via ServiceResult pattern (not exceptions)
- Both endpoints require authentication (inherits from BaseController)

### Prompt 7: RSpec Tests for Pokemon API (Stage 1)

```
Lets implement RSpec tests. We'll do it in two stages. Lets work on the first stage considering the following files with the indicated considerations:

app/adapters/pokemon_api_adapter.rb: This file use the PokeApi class to connect to thirdparty API. Let's use VCR to create cassettes for the test cases.
app/services/pokemon/fetch_service.rb: Lets use fake data (double of PokemonEntity) coming from the repository object, so no need to use VCR.
app/services/pokemon/list_service.rb: Lets use mimic data (double of array of hashes) coming from the repository object, so no need to use VCR.
app/repositories/pokemon_repository.rb: Just define mocking expectations on the adapter object
app/entities/pokemon_entity.rb: Basic attributes and to_h expectations.
```

**Test Files Created:**
- `spec/support/vcr.rb` - VCR configuration with WebMock
- `spec/entities/pokemon_entity_spec.rb` - Entity initialization and `to_h` tests
- `spec/value_objects/service_result_spec.rb` - Success/failure factory methods, immutability
- `spec/adapters/pokemon_api_adapter_spec.rb` - VCR cassettes for PokeAPI integration
- `spec/repositories/pokemon_repository_spec.rb` - Adapter delegation with mocks
- `spec/services/pokemon/fetch_service_spec.rb` - Mocked repository, ServiceResult responses
- `spec/services/pokemon/list_service_spec.rb` - Pagination logic, mocked repository

**Total: 72 tests, 0 failures**
