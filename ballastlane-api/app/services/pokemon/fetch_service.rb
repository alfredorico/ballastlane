module Pokemon
  class FetchService
    def initialize(repository: PokemonRepository.new)
      @repository = repository
    end

    def call(id)
      pokemon = @repository.find(id)

      if pokemon
        ServiceResult.success(pokemon.to_h)
      else
        ServiceResult.failure("Pokemon not found", code: :not_found)
      end
    end
  end
end
