require 'ruby2d'

@z = -1

module Ruby2D
  class Button < Rectangle
    attr_accessor :tag, :label

    def initialize opts = {}
      @tag = opts[:tag]
      @label = opts[:label] || 'button'

      opts[:color] = 'white'

      @border = Rectangle.new(z: opts[:z],
                              x: opts[:x] - 1,
                              y: opts[:y] - 1,
                              width: opts[:width] + 2,
                              height: opts[:height] + 2,
                              color: 'black')

      super opts

      @text = Text.new(z: opts[:z],
                       text: @label,
                       font: 'luximb.ttf',
                       size: 12,
                       color: 'black')

      arrange_text!
    end

    def arrange_text!
      @text.x = self.x + (self.width / 2) - @text.width / 2
      @text.y = self.y + (self.height / 2) - @text.height / 2
    end

    def resize_border!
      @border.width = self.width + 2
      @border.height = self.height + 2
    end

    def z= new_z
      @border.z = new_z
      super new_z
      @text.z = new_z
    end

    def translate dx, dy
      self.x = @x + dx
      self.y = @y + dy

      @text.x = @text.x + dx
      @text.y = @text.y + dy

      @border.x = @border.x + dx
      @border.y = @border.y + dy
    end

    def resize dx, dy
      self.width = @width + dx
      self.height = @height + dy

      resize_border!
      arrange_text!
    end

    def invert
      self.color = 'black'
      @border.color = 'white'
      @text.color = 'white'
    end

    def revert
      self.color = 'white'
      @border.color = 'black'
      @text.color = 'black'
    end
  end
end

@item = nil
@objects = []

set title: "..."
set background: 'white'

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
  height: 50
)

@objects << Button.new(
  z: z,
  x: 100,
  y: 100,
  width: 100,
  height: 50
)

def resizing? item, e
  ((item.x + item.width - 10)..(item.x + item.width)).cover?(e.x) &&
    ((item.y + item.height - 10)..(item.y + item.height)).cover?(e.y)
end

on :mouse_down do |e|
  @item = zord.find { |o| o.contains? e.x, e.y }

  next unless @item

  @item.invert

  @mtype = if resizing?(@item, e)
             :resize
           else
             :translate
           end
end

on :mouse_up do |e|
  @item.revert if @item
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
