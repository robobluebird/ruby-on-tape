require 'ruby2d'
require 'mini_magick'
require 'json'
require_relative 'graphic'
require_relative 'button'
require_relative 'mode'
require_relative 'text_box'
require_relative 'border'

@z = -1
@item = nil
@objects = []
@controls = []
@mode = Mode.new
@filename = 'test.json'
@name = nil
@created_at = nil
@updated_at = nil

set title: "..."
set background: 'white'

def write
  @updated_at = Time.now

  json = {}

  json[:name] = @name
  json[:created_at] = @created_at
  json[:updated_at] = @updated_at.to_i
  json[:cards] = [].tap do |rep|
    zord.reverse.each do |object|
      rep << object.to_h
    end
  end

  File.open(@filename, 'w') do |f|
    f.write JSON.pretty_generate json
  end
end

def read
  File.open(@filename) do |f|
    json = JSON.parse(f.read)

    @name = json['name']
    set title: @name

    @created_at = json['created_at']
    @updated_at = json['updated_at']

    json['cards'].each do |card|
      klazz = Object.const_get card['type'].split('_').map(&:capitalize).join
      @objects.push klazz.new card.reject { |k,v| k == 'type' }.map { |k,v| [k.to_sym, v] }.to_h.merge(z: z)
    end
  end
end

def reset
  @objects = []
  @item = nil
  @mode = Mode.new

  clear
end

def load_image filename
  Dir.mkdir 'images' rescue nil

  m = MiniMagick::Image.open filename

  m.colorspace 'gray'
  m.posterize 5
  m.resize '256x256'
  m.scale '50%'
  m.scale '200%'

  path = "images/#{filename}"

  m.write path

  Graphic.new path: path, z: z
end

def closer item
  return if item.nil?

  i = zord.index(item)
  closer_index = i - 1

  return if closer_index < 0

  n = zord[closer_index]

  z1, z2 = item.z, n.z
  item.z = z2
  n.z = z1

  write
end

def farther item
  return if item.nil?

  i = zord.index(item)
  n = zord[i + 1]

  return if n.nil?

  z1, z2 = item.z, n.z
  item.z = z2
  n.z = z1

  write
end

def z
  @z += 1
end

def zord
  @objects.sort { |a,b| b.z <=> a.z }
end

def resizing? item, e
  ((item.x + item.width - 10)..(item.x + item.width)).cover?(e.x) &&
    ((item.y + item.height - 10)..(item.y + item.height)).cover?(e.y)
end

on :mouse_down do |e|
  control = false

  if @item = @controls.find { |o| o.contains? e.x, e.y }
    control = true
  else
    @item = zord.find { |o| o.contains? e.x, e.y }
  end

  next unless @item

  @item.invert if @item.respond_to? :invert

  @mtype = if @mode.edit? && !control
             resizing?(@item, e) ? :resize : :translate
           end
end

on :mouse_up do |e|
  if @mode.edit? && !@controls.include?(@item)
    @focused.defocus if @focused
    @focused = nil
  end

  next unless @item

  @item.revert if @item && @item.respond_to?(:revert)

  if @mtype
    write
    @mtype = nil
  else
    if @item.respond_to?(:on_click) && @item.on_click
      eval @item.on_click
    end
  end

  if @mode.edit? && !@controls.include?(@item)
    @item.focus
    @focused = @item
  end

  @item = nil
end

on :mouse_move do |e|
  if @item && @mtype
    e.delta_x = 0 if (@item.x + e.delta_x < 0 && @mtype == :translate) || @item.x + @item.width + e.delta_x > get(:width) || @item.x + @item.width + e.delta_x < 0
    e.delta_y = 0 if (@item.y + e.delta_y < 0 && @mtype == :translate) || @item.y + @item.height + e.delta_y > get(:height) || @item.y + @item.height + e.delta_y < 0

    @item.send @mtype, e.delta_x, e.delta_y
  end
end

on :key_down do |e|
  if e.key.include? 'shift'
    @shift = true
  elsif e.key.include? 'command'
    @command = true
  end
end

on :key_up do |e|
  key = e.key

  if key.include? 'shift'
    @shift = false
    next
  elsif key.include? 'command'
    @command = false
    next
  end

  key = "shift_#{key}" if @shift
  key = "command_#{key}" if @command
  key = key.to_sym

  if @focused && @focused.editable?
    @focused.append key.to_s
    write
    next
  end

  if key == :e
    if @mode.edit?
      @mode.interact
      remove_controls
    else
      @mode.edit
      add_controls
    end
  end
end

def remove_controls
  @controls.each do |c|
    c.destroy
  end

  @controls.clear
end

def add_controls
  x = get(:width) - 110
  y = get(:height)

  @controls = [
    Button.new(label: 'new button', z: 1000, x: x, y: 10, width: 100, height: 25),
    Button.new(label: 'new text', z: 1000, x: x, y: 45, width: 100, height: 25),
    Button.new(label: 'new graphic', z: 1000, x: x, y: 80, width: 100, height: 25),
    Button.new(label: 'closer', z: 1000, x: x, y: y - 70, width: 100, height: 25, on_click: 'closer(@focused)'),
    Button.new(label: 'farther', z: 1000, x: x, y: y - 35, width: 100, height: 25, on_click: 'farther(@focused)')
  ]
end

read

show
