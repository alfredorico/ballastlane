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
