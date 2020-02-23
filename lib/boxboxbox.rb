module Boxboxbox
  class Image
    # @dynamic name, pathname
    attr_reader :name, :pathname

    def initialize(name:, pathname:)
      @name = name
      @pathname = pathname
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

  class Unzipper
    def unzip(zip_path:)
      [Image.new(name: "hogehoge", pathname: Pathname('aaa.jpg'))]
    end
  end
end 