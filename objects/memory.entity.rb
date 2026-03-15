require_relative '../../../system/memory'
require_relative './_toolkit'

# The memory class for all entities via Nataniev's memory system
class EntityMemory < Memory_Array

  def add(entity, add_children = false, parent_id = nil)

    return unless entity.is_a? Entity

    new_id      = length.to_s.prepend('0', 5)
    parent_id ||= entity.PRNT && !entity.PRNT.id.nil? ? entity.PRNT.id.append(' ', 6) : 'NULL0'
    language_id = entity.LANG_ID ? entity.LANG_ID.append(' ', 8) : 'NULL0'.append(' ', 8)
    type        = entity.TYPE.append(' ', 10)
    name        = entity.NAME.append(' ', 14)
    preposition = entity.PREP.append(' ', 50)
    adjective   = entity.ADJV.append(' ', 14)
    verb        = entity.VERB.append(' ', 20)
    adverb      = entity.ADVB.append(' ', 14)

    # Append this string to the entities.ma file
    append("#{new_id} #{parent_id} #{language_id} #{type} #{name} #{preposition} #{adjective} #{verb} #{adverb}")

    # Add directly to render, since append only adds a line to the file and doesn't re-render the memory
    # If this isn't done, then, among other things, the new_id gets messed up
    # when adding multiple things to memory during execution
    $entities.render << {
      'ID' => new_id,
      'P_ID' => parent_id,
      'LANG_ID' => language_id,
      'TYPE' => type,
      'NAME' => name,
      'PREP' => preposition,
      'ADJV' => adjective,
      'VERB' => verb,
      'ADVB' => adverb
    }

    if add_children && entity.CHLD.empty?
      entity.CHLD.each do |child|

        add(child, true, new_id)

      end
    end

    # Return the new id
    new_id

  end

  def get(id, with_children = false, _with_parent = false)

    id = id.to_s.prepend('0', 5) if id.is_a? Numeric

    entity_row = filter('ID', id, nil)[0]

    # Return the object
    entity = $archives.get(entity_row)

    if with_children
      # Fetch all entities that have a parent id of the entity's ID
      children_rows = filter('P_ID', id, nil)

      # Then, loop through the results and try to instantiate entity objects of them
      children_rows.each do |child|

        # Recursively fetch the entity and it's children
        c = get(child['ID'], true)
        entity.children.push(c)

      end
    end

    entity

  end

  def filter(field, value, type)

    a = []
    @render.each do |line|

      next if !line[field].to_s.like(value) && value != '*'

      a.push(type ? Object.const_get(type.capitalize).new(line) : line)

    end

    a

  end

end
