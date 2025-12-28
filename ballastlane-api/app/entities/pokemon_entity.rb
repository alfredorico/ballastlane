class PokemonEntity
  attr_reader :id, :name, :weight, :height, :types, :abilities, :photo, :description

  def initialize(attributes = {})
    @id = attributes[:id]
    @name = attributes[:name]
    @weight = attributes[:weight]
    @height = attributes[:height]
    @types = attributes[:types] || []
    @abilities = attributes[:abilities] || []
    @photo = attributes[:photo]
    @description = attributes[:description]
  end

  def to_h
    {
      id: id,
      name: name,
      weight: weight,
      height: height,
      types: types,
      abilities: abilities,
      photo: photo,
      description: description
    }
  end
end
