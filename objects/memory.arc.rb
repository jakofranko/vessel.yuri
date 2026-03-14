require_relative '../../../system/memory'
require_relative './arc'
require_relative './_toolkit'

# Arc Memory, for adding and getting arcs using Nataniev's memory system
class ArcMemory < Memory_Array

  def add(summary_id, order, text)

    new_id = length.to_s.prepend('0', 5)
    s_id = summary_id.prepend('0', 5).append(' ', 'summary_id'.length)
    o = order.append(' ', 24)

    # Append this string to the entities.ma file
    append("#{new_id} #{s_id} #{o} #{text}")

    new_id

  end

  def get(id)

    id = id.to_s if id.is_a? Numeric

    filter('id', id.prepend('0', 5), 'Arc').first

  end

  def get_by_summary_id(summary_id)

    filter('summary_id', summary_id.prepend('0', 5), 'Arc')

  end

end
