require_relative '../../../memory.rb'

class EntityMemory < Memory_Array

    def add entity

        new_id      = self.length.to_s.prepend("0", 5)
        parent_id   = entity.parent ? entity.parent.id : 'NULL0'
        type        = entity.type.append(" ", 10)
        name        = entity.name.append(" ", 14)
        adjective   = entity.adjective.append(" ", 14)
        verb        = entity.verb.append(" ", 20)
        adverb      = entity.adverb.append(" ", 14)
        # lang_id     = entity.lang_id

        self.append("#{new_id} #{parent_id.append(" ", 9)} #{type} #{name} #{adjective} #{verb} #{adverb}")

    end

end