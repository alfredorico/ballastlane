module Pokemon
  class ListService
    DEFAULT_PER_PAGE = 20

    def initialize(repository: PokemonRepository.new)
      @repository = repository
    end

    def call(page: 1, per_page: DEFAULT_PER_PAGE)
      page = [page.to_i, 1].max
      per_page = [per_page.to_i, 1].max
      offset = (page - 1) * per_page

      result = @repository.all(limit: per_page, offset: offset)

      if result
        ServiceResult.success(build_response(result, page, per_page))
      else
        ServiceResult.failure("Unable to fetch Pokemon list", code: :api_error)
      end
    end

    private

    def build_response(result, page, per_page)
      total = result[:count]
      total_pages = (total.to_f / per_page).ceil

      {
        pokemons: result[:results],
        pagination: {
          page: page,
          per_page: per_page,
          total: total,
          total_pages: total_pages,
          next_page: page < total_pages ? page + 1 : nil,
          previous_page: page > 1 ? page - 1 : nil
        }
      }
    end
  end
end
