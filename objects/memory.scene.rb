require_relative '../../../system/memory.rb'
require_relative './scene'
require_relative './_toolkit'

class SceneMemory < Memory_Array

    def add arc_id, time, action, setting

        new_id = self.length.to_s.prepend("0", 5)

        # Append this string to the entities.ma file
        self.append("#{new_id} #{arc_id.prepend("0", 5).append(" ", "arc_id".length + 1)} #{time.append(" ", 24)} #{action.append(" ", 52)}")

        return new_id

    end

    def get id

        if id.is_a? Numeric
            id = id.to_s.prepend("0", 5)
        end

        scene = self.filter('id', id, "Scene").first.symbolize_keys

        return scene

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
