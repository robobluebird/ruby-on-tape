require 'ruby2d'

@z = -1

module Ruby2D
  class MyImage < Image
    def initialize opts = {}
      super opts

      @rd = self.width > self.height ? :v : :h
      @r = @rd == :h ? self.height.to_f / self.width : self.width.to_f / self.height
    end

    def translate dx, dy
      self.x = @x + dx
      self.y = @y + dy
    end

    def resize dx, dy
      if !dx.zero?
        self.width = @width + dx

        if @rd == :h
          self.height = self.width / @r
        else
          self.height = self.width * @r
        end
      else
        self.height = @height + dy

        if @rd == :h
          self.width = self.height / @r
        else
          self.width = self.height * @r
        end
      end
    end
  end

  class Button < Rectangle
    attr_accessor :tag, :label, :show_border

    def initialize opts = {}
      @show_border = 1
      @tag = opts[:tag]
      @label = opts[:label] || 'button'

      opts[:color] = 'white'

      @border = Rectangle.new(z: opts[:z],
                              x: opts[:x] - 1,
                              y: opts[:y] - 1,
                              width: opts[:width] + 2,
                              height: opts[:height] + 2,
                              color: 'black')

      @shadow = Rectangle.new(z: opts[:z],
                              x: opts[:x] + 2,
                              y: opts[:y] + 2,
                              width: opts[:width],
                              height: opts[:height],
                              color: 'black')


      super opts

      @text = Text.new(z: opts[:z],
                       text: @label,
                       font: 'luximb.ttf',
                       size: 12,
                       color: 'black')

      arrange_text!
    end

    def show_border
      @border.opacity = 1
      @shadow.opacity = 1
      self.opacity = 1
      @show_border = 1
    end

    def hide_border
      @border.opacity = 0
      @shadow.opacity = 0
      self.opacity = 0
      @show_border = 0
    end

    def arrange_text!
      @text.x = self.x + (self.width / 2) - @text.width / 2
      @text.y = self.y + (self.height / 2) - @text.height / 2
    end

    def resize!
      @border.width = self.width + 2
      @border.height = self.height + 2
      @shadow.width = self.width
      @shadow.height = self.height
    end

    def z= new_z
      @border.z = new_z
      @shadow.z = new_z
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

      @shadow.x = @shadow.x + dx
      @shadow.y = @shadow.y + dy
    end

    def resize dx, dy
      self.width = @width + dx
      self.height = @height + dy

      resize!
      arrange_text!
    end

    def invert
      self.color = 'black'
      @text.color = 'white'
      @border.color = 'white'
      @shadow.color = 'white'
    end

    def revert
      self.color = 'white'
      @text.color = 'black'
      @border.color = 'black'
      @shadow.color = 'black'
      hide_border if @show_border.zero?
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

@objects << MyImage.new(path: 'tape.png')

def resizing? item, e
  ((item.x + item.width - 10)..(item.x + item.width)).cover?(e.x) &&
    ((item.y + item.height - 10)..(item.y + item.height)).cover?(e.y)
end

on :mouse_down do |e|
  @item = zord.find { |o| o.contains? e.x, e.y }

  next unless @item

  @item.invert if @item.respond_to? :invert

  @mtype = if resizing?(@item, e)
             :resize
           else
             :translate
           end
end

on :mouse_up do |e|
  @item.revert if @item && @item.respond_to?(:revert)
  @item = nil
  @mtype = nil
end

on :mouse_move do |e|
  if @item && @mtype
    e.delta_x = 0 if @item.x + @item.width + e.delta_x >= get(:width) || @item.x + e.delta_x <= 0
    e.delta_y = 0 if @item.y + @item.height + e.delta_y >= get(:height) || @item.y + e.delta_y <= 0
    @item.send @mtype, e.delta_x, e.delta_y
  end
end

toggle = 0
gtoggle = 0
on :key_up do |e|
  if e.key.to_sym == :f
    if toggle.zero?
      closer @objects.first
      toggle = 1
    else
      farther @objects.first
      toggle = 0
    end
  elsif e.key.to_sym == :g
    if gtoggle.zero?
      @objects.first.hide_border
      gtoggle = 1
    else
      @objects.first.show_border
      gtoggle = 0
    end
  end
end

show
