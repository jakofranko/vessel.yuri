class ActionListen

    include Action

    def initialize q = nil

        super

        @name = "Listen"
        @docs = "Yuri can listen to the untold. Tell him. An interactive tool for writing missing scenes and arcs."

        @arcs_by_summary = $summaries.to_a.inject({}) do |memo, summary|
            s_id = summary["id"]
            summary_arcs = $arcs.get_by_summary_id(s_id)
            memo.update(s_id => summary_arcs)
        end

    end

    # Ideas:
    # - What would you like to work on? (summaries, arcs, scenes)
    #   after selecting one, then you can either pick a parent and
    #   work within it, or you can pick a mode where you just write
    #   for the summary or arc with the fewest children.
    def act q = nil

        lowest_arcs = 99
        lowest_arcs_summary_id = nil
        lowest_arcs_summary = nil
        @arcs_by_summary.each_pair do |k, v|
            if v.length < lowest_arcs then
                lowest_arcs = v.length
                lowest_arcs_summary_id = k
            end
        end

        lowest_arcs_summary = $summaries
            .to_a
            .select {|summary| summary['id'] == lowest_arcs_summary_id }
            .first

        puts "Write an arc for summary ID #{lowest_arcs_summary_id} (it has only #{lowest_arcs} arcs)"
        puts "Summary: #{lowest_arcs_summary['summary']}"
        puts "Current arcs: #{$arcs.get_by_summary_id(lowest_arcs_summary_id).map{|arc| [arc.order, arc.text] }}"
        puts "Input arc text:"
        arc = STDIN.gets.chomp
        puts "What order does this arc have? (number, can be comma seperated)"
        order = STDIN.gets.chomp
        puts "Adding arc: #{arc}, order: #{order}, for summary ID: #{lowest_arcs_summary_id}"
        new_arc_id = $arcs.add(lowest_arcs_summary_id, order, arc)
        puts "done.\n\n"
        puts "Now, write some scenes for that new arc (arc ID #{new_arc_id}) "

    end

end
