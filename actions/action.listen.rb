class ActionListen

    include Action

    def initialize q = nil

        super

        @name = "Listen"
        @docs = "Yuri can listen to the untold. Tell him. An interactive tool for writing missing scenes and arcs."

        $tags ||= Memory_Array.new("story_templates/tags", @host.path)
        $summaries ||= Memory_Array.new("story_templates/summaries", @host.path)
        $arcs ||= ArcMemory.new("story_templates/arcs", @host.path)
        $scenes ||= SceneMemory.new("story_templates/scenes", @host.path)

        @arcs_by_summary = $summaries.to_a.inject({}) do |memo, summary|
            s_id = summary["id"]
            summary_arcs = $arcs.get_by_summary_id(s_id)
            memo.update(s_id => summary_arcs)
        end

        @scenes_by_arc = $arcs.to_a.inject({}) do |memo, arc|
            arc_id = arc["id"]
            arc_scenes = $scenes.get_by_arc_id(arc_id)
            memo.update(arc_id => arc_scenes)
        end

    end

    # Ideas:
    # - What would you like to work on? (summaries, arcs, scenes)
    #   after selecting one, then you can either pick a parent and
    #   work within it, or you can pick a mode where you just write
    #   for the summary or arc with the fewest children.
    def act q = nil

        if !q.nil? && q != "" then
            topic = q
        else
            puts "What would you like to work on?"
            puts "(summaries, arcs, or scenes)"
            topic = STDIN.gets.chomp
        end

        case topic
        when "arcs"
            listen_arcs
        when "scenes"
            listen_scenes
        else
            puts "#{topic} is not a valid option"
            return nil
        end

    end

    def listen_arcs

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

    def listen_scenes

        lowest_scenes = 999
        lowest_scenes_arc_id = nil
        lowest_scenes_arc = nil
        lowest_scenes_arc_summary = nil
        @scenes_by_arc.each_pair do |k, v|
            if v.length < lowest_scenes then
                lowest_scenes = v.length
                lowest_scenes_arc_id = k
            end
        end

        lowest_scenes_arc = $arcs
            .to_a
            .select {|arc| arc['id'] == lowest_scenes_arc_id }
            .first
        lowest_scenes_arc_summary = $summaries
            .to_a
            .select {|summary| summary["id"] == lowest_scenes_arc["summary_id"] }
            .first

        puts "Write a scene for arc ID #{lowest_scenes_arc_id} (it has only #{lowest_scenes} scenes)"

        continue = 'y'
        while continue
            puts "Story Summary: #{lowest_scenes_arc_summary['summary']}"
            puts "Arc Text: #{lowest_scenes_arc['text']}"
            puts "Current scenes: #{$scenes.get_by_arc_id(lowest_scenes_arc_id).map{|scene| [scene.order, scene.describe] }}"
            puts "The following tags can be used (use the 'tag' exactly as written (including carats <>)):"
            $tags.to_a.each{|t| puts "Tag: #{t["tag"]}, Type: #{t["entity"]}"}
            puts "Input TIME description:"
            time = STDIN.gets.chomp
            puts "Input ACTION description:"
            action = STDIN.gets.chomp
            puts "Input SETTING description:"
            setting = STDIN.gets.chomp
            puts "Input ORDER this scene should appear in (can be comma separated):"
            order = STDIN.gets.chomp
            puts "Creating scene..."
            $scenes.add(lowest_scenes_arc_id, time, action, setting, order)
            puts "Scene created."
            puts "Continue creating scenes for arc #{lowest_scenes_arc_id}? (y/n)"

            continue = STDIN.gets.chomp

            break unless continue == 'y'
        end

    end
end
