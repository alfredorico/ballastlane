module Api
  module V1
    class PokemonsController < BaseController
      def index
        result = list_service.call(page: pagination_params[:page], per_page: pagination_params[:per_page])
        handle_result(result)
      end

      def show
        result = fetch_service.call(params[:id])
        handle_result(result)
      end

      private

      # Minor refactoring to be DRY.
      def handle_result(result)
        if result.success?
          render_success(result.data)
        else
          render_error(result.error, status: error_status(result.code))
        end
      end

      def pagination_params
        {
          page: params[:page] || 1,
          per_page: params[:per_page] || Pokemon::ListService::DEFAULT_PER_PAGE
        }
      end

      def fetch_service
        @fetch_service ||= Pokemon::FetchService.new
      end

      def list_service
        @list_service ||= Pokemon::ListService.new
      end

      def error_status(code)
        # Here we do a translation of business code into HTTP code. 
        # Services classes shouldn't be aware of HTTP codes.
        case code
        when :not_found then :not_found
        when :api_error then :service_unavailable
        else :unprocessable_content
        end
      end
    end
  end
end
