class PokemonRepository
  def initialize(adapter: PokemonApiAdapter.new)
    @adapter = adapter
  end

  def find(id)
    @adapter.find(id)
  end

  def all(limit: 20, offset: 0)
    @adapter.all(limit: limit, offset: offset)
  end
end
