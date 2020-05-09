require_relative '../../../system/memory.rb'
require_relative './_toolkit'

class StoryArcMemory < Memory_Array

    def add story_arc, story_id, order

        new_id = self.length.to_s.prepend("0", 5)
        story_id = story_id.append(" ", 8)
        order = order.to_s.append(" ", 5)
        text = story_arc["text"]

        self.append("#{new_id} #{story_id} #{order} #{text}")

        new_id

    end

end
