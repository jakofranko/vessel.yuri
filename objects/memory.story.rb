require_relative '../../../system/memory.rb'
require_relative './story'
require_relative './_toolkit'

class StoryMemory < Memory_Array

    def add world_id, summary

        new_id = self.length.to_s.prepend("0", 5)

        # Append this string to the entities.ma file
        self.append("#{new_id} #{world_id.prepend("0", 5).append(" ", "world_id".length)} #{summary}")

        return new_id

    end

    def get id

        if id.is_a? Numeric
            id = id.to_s.prepend("0", 5)
        end

        story = self.filter('id', id, "Story").first

        return story

    end

    def get_by_arc_id arc_id

        return self.filter("arc_id", arc_id.prepend("0", 5), "Scene")

    end

    def describe

        self.each { |x, y|
            puts x
            puts y
        }

    end

end
