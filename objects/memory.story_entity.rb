require_relative '../../../system/memory.rb'
require_relative './_toolkit'

class StoryEntityMemory < Memory_Array

    def add entity, data

        new_id = self.length.to_s.prepend("0", 5)
        entity_id = entity.ID.nil? ? "BLANK" : entity.ID
        story_id = data[:story_id].nil? ? "BLANK" : data[:story_id]
        # location_id = entity.location.nil? ? "BLANK" : entity.location.id

        # Adjust spacing
        entity_id = entity_id.append(" ", 9)
        story_id = story_id.append(" ", 8)

        # Append this string to the entities.ma file
        self.append("#{new_id} #{entity_id} #{story_id} #{entity.NAME}")

        # Return the new id
        new_id

    end

    def get id

        if id.is_a? Numeric
            id = id.to_s.prepend("0", 5)
        end

        entity_row = self.filter('id', id, nil)[0].symbolize_keys

        # Return the object
        entity = Object.const_get('Entity').new(entity_row)

        entity

    end

end
