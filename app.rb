require 'ruby2d'

@z = -1

module Ruby2D
  class Button < Rectangle
    attr_accessor :tag, :label

    def initialize opts = {}
      @tag = opts[:tag]
      @label = opts[:label] || 'button'

      super opts
    end

    def translate dx, dy
      self.x = @x + dx
      self.y = @y + dy
    end

    def resize dx, dy
      self.width = @width + dx
      self.height = @height + dy
    end
  end

  class Image
    def translate dx, dy
      @x += dx
      @y += dy
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

@item = nil
@objects = []

set title: "..."

def closer item
  i = zord.index(item)
  n = zord[i - 1]

  return if n.nil?

  z1, z2 = item.z, n.z
  item.z = z2
  n.z = z1
end

def farther item
  i = zord.index(item)
  n = zord[i + 1]

  return if n.nil?

  z1, z2 = item.z, n.z
  item.z = z2
  n.z = z1
end

def z
  @z += 1
end

def zord
  @objects.sort { |a,b| b.z <=> a.z }
end

@objects << Button.new(
  z: z,
  x: 100,
  y: 100,
  width: 100,
  height: 50,
  color: 'blue'
)

@objects << Button.new(
  z: z,
  x: 100,
  y: 100,
  width: 100,
  height: 50,
  color: 'red'
)

on :mouse_down do |e|
  @item = zord.find { |o| o.contains? e.x, e.y }
  @mtype = if ((@item.x + @item.width - 10)..(@item.x + @item.width)).cover?(e.x) &&
               ((@item.y + @item.height - 10)..(@item.y + @item.height)).cover?(e.y)
             :resize
           else
             :translate
           end
end

on :mouse_up do |e|
  @item = nil
  @mtype = nil
end

on :mouse_move do |e|
  @item.send @mtype, e.delta_x, e.delta_y if @item && @mtype
end

toggle = 0
on :key_up do |e|
  if e.key.to_sym == :f
    if toggle.zero?
      closer @objects.first
      toggle = 1
    else
      farther @objects.first
      toggle = 0
    end
  end
end

show
