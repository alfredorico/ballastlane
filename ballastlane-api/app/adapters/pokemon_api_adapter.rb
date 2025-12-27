class PokemonApiAdapter
  def find(id)
    pokemon = PokeApi.get(pokemon: id)
    return nil unless pokemon

    build_pokemon_entity(pokemon)
  rescue StandardError
    nil
  end

  def all(limit: 20, offset: 0)
    response = PokeApi.get(pokemon: { limit: limit, offset: offset })
    return nil unless response
    {
      results: parse_list_results(response.results),
      count: response.count,
      # next: response.next,        # CLAUDE mistake
      # previous: response.previous # CLAUDE mistake
    }
  rescue StandardError
    nil
  end

  private

  def build_pokemon_entity(pokemon)
    attributes = extract_basic_attributes(pokemon)
    attributes.merge!(extract_sprites(pokemon))
    attributes[:types] = extract_types(pokemon)
    attributes[:abilities] = extract_abilities(pokemon)
    attributes[:description] = extract_description(pokemon)

    PokemonEntity.new(attributes)
  end

  def extract_basic_attributes(pokemon)
    {
      id: pokemon.id,
      name: pokemon.name,
      weight: pokemon.weight / 10.0,
      height: pokemon.height / 10.0
    }
  end

  def extract_types(pokemon)
    pokemon.types.map { |t| t.type.name }
  end

  def extract_abilities(pokemon)
    pokemon.abilities.map { |a| a.ability.name }
  end

  def extract_sprites(pokemon)
    {
      photo: pokemon.sprites.front_default
    }
  end

  def extract_description(pokemon)
    species = pokemon.species.get
    english_entry = species.flavor_text_entries.find { |entry| entry.language.name == "en" }
    english_entry&.flavor_text&.gsub(/[\n\f]/, " ")
  rescue StandardError
    nil
  end

  def parse_list_results(results)
    results.map do |result|
      id = extract_id_from_url(result.url)
      {
        id: id,
        name: result.name,
        photo: sprite_url(id)
      }
    end
  end

  def extract_id_from_url(url)
    url.to_s.split("/").reject(&:empty?).last.to_i
  end

  def sprite_url(id)
    "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/#{id}.png"
  end
end
