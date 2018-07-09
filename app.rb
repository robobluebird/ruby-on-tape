require 'ruby2d'

DEFAULT_Z = 0

module Ruby2D
  class Rectangle
    def translate dx, dy
    end
  end

  class Image
    def translate dx, dy
    end
  end

  class Triangle
    def translate dx, dy
      @x1 += dx
      @y1 += dy
      @x2 += dx
      @y2 += dy
      @x3 += dx
      @y3 += dy
    end
  end
end

item = nil
objects = []

set title: "Hello Triangle"

objects << Triangle.new(
  z: DEFAULT_Z,
  x1: 320, y1:  50,
  x2: 540, y2: 430,
  x3: 100, y3: 430,
  color: ['red', 'green', 'blue']
)

on :mouse_down do |e|
  item = objects.find do |o|
    o.contains? e.x, e.y
  end
end

on :mouse_up do |e|
  item = nil
end

on :mouse_move do |e|
  if item
    item.translate(e.delta_x, e.delta_y)
  end
end

show
