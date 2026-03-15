require_relative '../../../system/memory'
require_relative './_toolkit'

# Memory of a story's entities via the Nataniev memory system
class StoryEntityMemory < Memory_Array

  def add(entity, data)

    new_id = length.to_s.prepend('0', 5)
    entity_id = entity.ID.nil? ? 'BLANK' : entity.ID
    story_id = data[:story_id].nil? ? 'BLANK' : data[:story_id]
    # location_id = entity.location.nil? ? "BLANK" : entity.location.id

    # Adjust spacing
    e_id = entity_id.append(' ', 9)
    s_id = story_id.append(' ', 8)

    # Append this string to the entities.ma file
    append("#{new_id} #{e_id} #{s_id} #{entity.NAME}")

    # Return the new id
    new_id

  end

  def get(id)

    id = id.to_s.prepend('0', 5) if id.is_a? Numeric

    entity_row = filter('id', id, nil)[0].symbolize_keys

    # Return the object
    Object.const_get('Entity').new(entity_row)

  end

end
