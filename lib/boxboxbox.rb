# frozen_string_literal: true

require 'boxboxbox/unzipper'
require 'boxboxbox/box_localizer.rb'

module Boxboxbox
  class BinaryImage
    # @dynamic name, binary
    attr_reader :name, :binary

    def initialize(name:, binary:)
      @name = name
      @binary = binary
    end
  end

  class Point
    # @dynamic x, y
    attr_reader :x, :y

    def initialize(x:, y:)
      @x = x
      @y = y
    end
  end

  class Box
    # @dynamic image_name, top_left, bottom_right
    attr_reader :image_name, :top_left, :bottom_right

    def initialize(image_name:, top_left:, bottom_right:)
      @image_name = image_name
      @top_left = top_left
      @bottom_right = bottom_right
    end
  end
end
