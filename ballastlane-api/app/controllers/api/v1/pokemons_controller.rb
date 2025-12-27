module Api
  module V1
    class PokemonsController < BaseController
      def index
        result = list_service.call(page: pagination_params[:page], per_page: pagination_params[:per_page])

        if result.success?
          render_success(result.data)
        else
          render_error(result.error, status: :service_unavailable)
        end
      end

      def show
        result = fetch_service.call(params[:id])

        if result.success?
          render_success(result.data)
        else
          render_error(result.error, status: error_status(result.code))
        end
      end

      private

      def pagination_params
        {
          page: params[:page] || 1,
          per_page: params[:per_page] || 20
        }
      end

      def fetch_service
        @fetch_service ||= Pokemon::FetchService.new
      end

      def list_service
        @list_service ||= Pokemon::ListService.new
      end

      def error_status(code)
        case code
        when :not_found then :not_found
        when :api_error then :service_unavailable
        else :unprocessable_entity
        end
      end
    end
  end
end
