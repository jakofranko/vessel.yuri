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

    def act q = nil

        @arcs_by_summary.each_pair {|k, v| puts "Summary ID #{k} has #{v.length} arcs"}


    end

end
