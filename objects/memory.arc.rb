require_relative '../../../system/memory.rb'
require_relative './arc'
require_relative './_toolkit'

class ArcMemory < Memory_Array

    def add summary_id, order, text

        new_id = self.length.to_s.prepend("0", 5)

        # Append this string to the entities.ma file
        self.append("#{new_id} #{summary_id.prepend("0", 5).append(" ", "summary_id".length)} #{order.append(" ", 24)} #{text}")

        return new_id

    end

    def get id

        if id.is_a? Numeric
            id = id.to_s
        end

        arc_row = self.filter('id', id.prepend("0", 5), "Arc").first

        return arc_row

    end

    def get_by_summary_id summary_id

        return self.filter("summary_id", summary_id.prepend("0", 5), "Arc")

    end

end
