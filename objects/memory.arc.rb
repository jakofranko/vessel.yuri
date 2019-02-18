require_relative '../../../system/memory.rb'
require_relative './_toolkit'

class ArcMemory < Memory_Array

    def add summary_id, order, text

        new_id = self.length.to_s.prepend("0", 5)

        # Append this string to the entities.ma file
        self.append("#{new_id} #{summary_id.prepend("0", 5).append(" ", "summary_id".length + 1)} #{order.append(" ", 25)} #{text}")

        return new_id

    end

    def get id

        if id.is_a? Numeric
            id = id.to_s.prepend("0", 5)
        end

        arc_row = self.filter('id', id, nil).first.symbolize_keys

        return arc_row

    end

    def get_by_summary_id summary_id

        return self.filter("summary_id", summary_id.prepend("0", 5), nil)

    end

end
