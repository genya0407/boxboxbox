# frozen_string_literal: true

require 'csv'

module Boxboxbox
  module BoxPresenter
    class Csv
      def present(boxes:)
        ::CSV.generate do |csv|
          csv << %w[name top_left_x top_left_y bottom_right_x bottom_right_y]
          boxes.each do |box|
            csv << [box.image_name, box.top_left.x, box.top_left.y, box.bottom_right.x, box.bottom_right.y]
          end
        end
      end
    end
  end
end
