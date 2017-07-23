require_relative '../../../memory.rb'

class EntityMemory < Memory_Array

    def add entity

        if !entity.is_a? Entity then return end

        new_id      = self.length.to_s.prepend("0", 5)
        parent_id   = (entity.parent && !entity.parent.id.nil?) ? entity.parent.id : 'NULL0'
        type        = entity.type.append(" ", 10)
        name        = entity.name.append(" ", 14)
        preposition = entity.preposition.append(" ", 50)
        adjective   = entity.adjective.append(" ", 14)
        verb        = entity.verb.append(" ", 20)
        adverb      = entity.adverb.append(" ", 14)
        # lang_id     = entity.lang_id

        # Append this string to the entities.ma file
        self.append("#{new_id} #{parent_id.append(" ", 9)} #{type} #{name} #{preposition} #{adjective} #{verb} #{adverb}")

        # Add directly to render, since append only adds a line to the file and doesn't re-render the memory
        # If this isn't done, then, among other things, the new_id gets messed up when adding multiple things to memory during execution
        $entities.render << {"id"=>new_id, "parent_id"=>parent_id, "type"=>type, "name"=>name, "preposition"=>preposition, "adjective"=>adjective, "verb"=>verb, "adverb"=>adverb}

        # Return the new id
        new_id

    end

    def get id, with_children = false, with_parent = false

        if id.is_a? Numeric
            id = id.to_s.prepend("0", 5)
        end

        entity_row = self.filter('id', id, nil)[0]

        # Symbolize keys
        entity_row = Hash[entity_row.map { |k, v| [k.to_sym, v] }]

        # Return the object
        Object.const_get(entity_row[:type].capitalize).new(entity_row)

    end

    def filter field, value, type

        a = []
        @render.each do |line|
          if !line[field].to_s.like(value) && value != "*" then next end
          a.push(type ? Object.const_get(type.capitalize).new(line) : line)
        end
        return a

    end


end