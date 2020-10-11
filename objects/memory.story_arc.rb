require_relative '../../../system/memory.rb'
require_relative './_toolkit'

class StoryArcMemory < Memory_Array

    def add story_arc, story_id, order

        new_id = self.length.to_s.prepend("0", 5)
        story_id = story_id.append(" ", 8)
        arc_template_id = story_arc.id.append(" ", 15)
        order = order.to_s.append(" ", 5)
        text = story_arc.text

        self.append("#{new_id} #{story_id} #{arc_template_id} #{order} #{text}")

        new_id

    end

    def get_by_template_id arc_template_id, story_id = nil

        if story_id.nil? then
            return self.filter("ARC_TEMPLATE_ID", arc_template_id, nil)
        else
            return self.filter("STORY_ID", story_id, nil)
        end

    end

end
