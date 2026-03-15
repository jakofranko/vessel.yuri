require_relative '../../../system/memory'
require_relative './story'
require_relative './_toolkit'

# Memory of stories via Nataniev's memory system
class StoryMemory < Memory_Array

  def add(world_id, summary)

    new_id = length.to_s.prepend('0', 5)

    # Append this string to the entities.ma file
    append("#{new_id} #{world_id.prepend('0', 5).append(' ', 'world_id'.length)} #{summary}")

    new_id

  end

  def get(id)

    id = id.to_s.prepend('0', 5) if id.is_a? Numeric

    filter('id', id, 'Story').first

  end

  def get_by_arc_id(arc_id)

    filter('arc_id', arc_id.prepend('0', 5), 'Scene')

  end

  def describe

    each do |x, y|

      puts x
      puts y

    end

  end

end
