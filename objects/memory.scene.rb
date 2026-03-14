require_relative '../../../system/memory'
require_relative './scene'
require_relative './_toolkit'

# Scene memory, for adding and getting scenes via Nataniev's memory system
class SceneMemory < Memory_Array

  def add(arc_id, time, action, setting, order)

    new_id = length.to_s.prepend('0', 5)
    formatted_arc_id = arc_id.prepend('0', 5).append(' ', 'arc_id'.length)
    formatted_order = order.append(' ', 5)
    formatted_setting = setting.append(' ', 59)
    formatted_time = time.append(' ', 49)

    # Append this string to the entities.ma file
    append("#{new_id} #{formatted_arc_id} #{formatted_order} #{formatted_setting} #{formatted_time} #{action}")

    new_id

  end

  def get(id)

    id = id.to_s.prepend('0', 5) if id.is_a? Numeric

    filter('ID', id, 'Scene').first.symbolize_keys

  end

  def get_by_arc_id(arc_id)

    filter('ARC_ID', arc_id.prepend('0', 5), 'Scene')

  end

end
