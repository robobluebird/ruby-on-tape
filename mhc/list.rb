module Ruby2D
  class List
    attr_reader :x, :y, :width, :height, :z, :items, :rendered_items

    def initialize opts = {}
      extend Ruby2D::DSL

      @visible = false
      @listener = opts[:listener]
      @rendered = false
      @mouse_over = false
      @z = opts[:z] || 0
      @x = opts[:x] || 0
      @y = opts[:y] || 0
      @width = opts[:width] || 100
      @height = opts[:height] || 122
      @items = opts[:items] || []
      @rendered_items = []
      @item_height = opts[:item_height] || 20
      @start_index = 0
      @end_index = [@items.count, ((@height - 2).to_f / @item_height).floor - 1].min
    end

    def objectify
      [self] + @rendered_items
    end

    def visible?
      @visible
    end

    def remove
      raise "Can't remove before being added" unless @rendered

      @border.remove
      @content.remove
      @rendered_items.each { |ri| ri.remove }

      @visible = false

      self
    end

    def add
      if @rendered
        @border.add
        @content.add
      else
        render!
      end

      @visible = true

      self
    end

    def contains? x, y
      (@content.x..(@content.x + @content.width)).cover?(x) &&
        (@content.y..(@content.y + @content.height)).cover?(y)
    end

    def choose item
      if @listener
        @listener.choose item
      else
        p "Chose #{item} but there's nothing to do with it!"
      end
    end

    def items= items
      @items = items
      @start_index = 0
      @end_index = [@items.count, ((@height - 2).to_f / @item_height).floor - 1].min

      layout_items!
    end

    def mouse_down x, y, button
    end

    def mouse_up x, y, button
    end

    def hover_on x, y
      @last_mouse_x = x
      @last_mouse_y = y
    end

    def hover_off x, y
      @last_mouse_x = nil
      @last_mouse_y = nil
    end

    def scroll dx, dy
      change = if dy > 0
                 [dy, @items.length - 1 - @end_index].min
               elsif dy < 0
                 [dy, 0 - @start_index].max
               else
                 0
               end

      @start_index += change
      @end_index += change

      render_items!

      @rendered_items.each do |ri|
        if ri.contains? @last_mouse_x, @last_mouse_y
          ri.invert
        else
          ri.revert
        end
      end
    end

    private

    def layout_items!
      @rendered_items.each { |ri| ri.remove }
      @rendered_items.clear

      y = @content.y

      @items.each do |item|
        item_element = Label.new(
          listener: self,
          action: "choose '#{item}'",
          text: item,
          z: @z,
          x: @content.x,
          y: y,
          width: @content.width,
          height: @item_height
        )

        y += @item_height

        item_element.add

        @rendered_items << item_element
      end

      render_items!
    end

    def render_items!
      @rendered_items.each { |ri| ri.remove }

      y = @content.y

      @rendered_items[@start_index..@end_index].each do |ri|
        ri.x = @content.x
        ri.y = y
        ri.add
        y += @item_height
      end
    end

    def render!
      @border = Border.new(
        z: @z,
        x: @x,
        y: @y,
        width: @width,
        height: @height
      )

      @content = Rectangle.new(
        z: @z,
        x: @x + @border.thickness,
        y: @y + @border.thickness,
        width: @width - (@border.thickness * 2),
        height: @height - (@border.thickness * 2)
      )

      layout_items!

      @rendered = true
    end
  end
end
