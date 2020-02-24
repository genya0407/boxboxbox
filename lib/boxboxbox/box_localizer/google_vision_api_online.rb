# frozen_string_literal: true

require 'typhoeus'
require 'concurrent'
require 'base64'
require 'logger'

module Boxboxbox
  module BoxLocalizer
    class GoogleVisionApiOnline
      URL = 'https://vision.googleapis.com/v1/images:annotate'
      PERSON_LABEL = 'Person'

      def initialize(access_token:, max_results:, min_percentage:, max_retry:, logger: Logger.new(STDERR))
        @access_token = access_token
        @max_results = max_results
        @min_percentage = min_percentage
        @max_retry = max_retry
        @logger = logger
      end

      def localize(images:)
        # rubocop:disable Style/EmptyLiteral
        boxes = Array.new
        remaining_retry_count = @max_retry

        # 失敗したらmax_retry回リトライする。
        # リトライの間隔は指数的に伸ばす
        loop do
          result = exec_request(images: images)
          boxes.concat(result[:success_boxes])

          break if result[:failed_images].empty?
          break if remaining_retry_count.zero?

          sleep(2**(@max_retry - remaining_retry_count))
          remaining_retry_count -= 1
          images = result[:failed_images]
        end

        boxes
      end

      private

      def exec_request(images:)
        hydra = Typhoeus::Hydra.new
        success_boxes = Concurrent::Array.new
        failed_images = Concurrent::Array.new

        images.each do |image|
          request = generate_request(image_content: image.binary)
          request.on_complete do |response|
            if response.success?
              vertices = response2vertices(response_body: response.response_body)
              success_boxes << vertices2box(image_name: image.name, vertices: vertices)
            else
              @logger.warn("#{__FILE__}:#{__LINE__}") { response.response_body }
              failed_images << image
            end
          end
          hydra.queue request
        end

        hydra.run

        { success_boxes: success_boxes.to_a, failed_images: failed_images.to_a }
      end

      def vertices2box(image_name:, vertices:)
        xs = vertices.map { |vertice| vertice[:x]&.to_f || 0 }
        ys = vertices.map { |vertice| vertice[:y]&.to_f || 0 }
        Boxboxbox::Box.new(
          image_name: image_name,
          top_left: Boxboxbox::Point.new(x: xs.min || 0, y: ys.min || 0),
          bottom_right: Boxboxbox::Point.new(x: xs.max || 0, y: ys.max || 0)
        )
      end

      def response2vertices(response_body:)
        JSON.parse(response_body, symbolize_names: true)
            .dig(:responses, :localizedObjectAnnotations)
            .select { |annot| annot[:name] == PERSON_LABEL }
            .select { |annot| annot[:score] >= @min_percentage }
            .map { |annot| annot[:boundingPoly][:vertices] }
      end

      def generate_request(image_content:)
        Typhoeus::Request.new(
          URL,
          method: :post,
          params: { key: @access_token },
          headers: { 'Content-Type': 'application/json; charset=utf-8' },
          body: JSON.generate(
            {
              "requests": [
                {
                  "image": {
                    "content": Base64.encode64(image_content)
                  },
                  "features": [
                    {
                      "maxResults": @max_results,
                      "type": 'OBJECT_LOCALIZATION'
                    }
                  ]
                }
              ]
            }
          )
        )
      end
    end
  end
end
