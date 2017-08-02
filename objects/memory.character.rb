require_relative '../../../system/memory.rb'
require_relative './_toolkit'

class CharacterMemory < Memory_Array

    def add character

        if !character.is_a? Character then return end

        new_id = self.length.to_s.prepend("0", 5)
        location_id = character.location.nil? ? character.location.id : "BLANK"
        language_id = character.language_id.to_s.prepend("0", 5)

        # Append this string to the entities.ma file
        self.append("#{new_id} #{character.name.append(" ", 20)}#{location_id.prepend("0", 5).append(" ", 16)}#{language_id.prepend("0", 5)}")

        # Add directly to render, since append only adds a line to the file and doesn't re-render the memory
        # If this isn't done, then, among other things, the new_id gets messed up when adding multiple things to memory during execution
        $characters.render << {"id"=>new_id, "name"=>character.name, "location_id"=>location_id, "language_id"=>language_id, }

        # Return the new id
        new_id

    end

    def get id

        if id.is_a? Numeric
            id = id.to_s.prepend("0", 5)
        end

        character_row = self.filter('id', id, nil)[0].symbolize_keys

        # Return the object
        character = Object.const_get('Character').new(character_row)

        character

    end

end