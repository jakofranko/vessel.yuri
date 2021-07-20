require_relative '../../../system/memory.rb'
require_relative './_toolkit'

class StoryArcMemory < Memory_Array

    def add story_arc, story_id, order

        story_arc_id = story_arc.respond_to?(:id) ? story_arc.id : story_arc["ID"]
        story_arc_text = story_arc.respond_to?(:text) ? story_arc.text : story_arc["TEXT"]
        new_id = self.length.to_s.prepend("0", 5)
        story_id = story_id.append(" ", 8)
        arc_template_id = story_arc_id.append(" ", 15)
        order = order.to_s.append(" ", 5)
        text = story_arc_text

        self.append("#{new_id} #{story_id} #{arc_template_id} #{order} #{text}")

        new_id

    end

    def get_by_template_id arc_template_id, story_id = nil

        arcs = self.filter("ARC_TEMPLATE_ID", arc_template_id, nil)

        if story_id then
            return arcs.select {|arc| arc["STORY_ID"] == story_id }
        end

        return arcs
    end

    def get_by_story_id story_id

        self.filter("STORY_ID", story_id, nil)

    end

end
