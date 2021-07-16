require_relative '../../../system/memory.rb'
require_relative './scene'
require_relative './_toolkit'

class StoryArcSceneMemory < Memory_Array

    def add arc_id, time, action, setting, order

        new_id = self.length.to_s.prepend("0", 5)
        formatted_arc_id = arc_id.prepend("0", 5).append(" ", "arc_id".length)
        formatted_order = order.append(" ", 5)
        formatted_setting = setting.append(" ", 59)
        formatted_time = time.append(" ", 49)

        # Append this string to the entities.ma file
        self.append("#{new_id} #{formatted_arc_id} #{formatted_order} #{formatted_setting} #{formatted_time} #{action}")

        return new_id

    end

    def get id

        if id.is_a? Numeric
            id = id.to_s.prepend("0", 5)
        end

        scene = self.filter('ID', id, "Scene").first.symbolize_keys

        return scene

    end

    def get_by_arc_id arc_id

        return self.filter("ARC_ID", arc_id.prepend("0", 5), "Scene")

    end

end
