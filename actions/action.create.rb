require_relative "../objects/memory.arc"

class ActionCreate

    include Action

    @@indent = "\s" * 4
    @@entity_type_num_args = 7
    @@entity_type_template = "" \
        "TYPE : %s\n" \
        "CMAX : %s\n\n" \
        "ADJV\n#{@@indent}%s\n\n" \
        "VERB\n#{@@indent}%s\n\n" \
        "ADVB\n#{@@indent}%s\n\n" \
        "CTPS\n#{@@indent}%s\n\n" \
        "CPRP\n#{@@indent}%s\n\n" \


    def initialize q = nil

        super

        @name = "Create"
        @docs = "Create new memories. Current commands: `create entity_type`, `create arc`, `create scene`"

    end

    def act q = nil

        raise "You must specify what you want to create..." unless !q.nil?

        $tags ||= Memory_Array.new("story_templates/tags", @host.path)
        $summaries ||= Memory_Array.new("story_templates/summaries", @host.path)
        $arcs ||= ArcMemory.new("story_templates/arcs", @host.path)
        $scenes ||= SceneMemory.new("story_templates/scenes", @host.path)

        args = q.split(' ')
        case args.first
        when 'entity_type'
            raise "You must at least specify the type of entity you are wanting to create e.g., `create entity_type Water`" unless args.length > 1
            create_entity_type(args[1..-1])
        when 'arc'
            start_arc_creator
        when 'scene'
            start_scene_creator
        else
            puts "\"#{args.first}\" is not something #{@host.name} can create right now."
        end

    end

    private

    def create_entity_type attrs = []

        @@entity_type_num_args.times do |i|
            next if attrs[i]
            attrs[i] = ''
        end

        new_file = File.new("#{@host.path}/memory/world_generation/entity_types/#{attrs.first.downcase}.mh", "w")
        new_file.puts(@@entity_type_template % attrs)
        new_file.close

        puts @@entity_type_template % attrs

    end

    def start_arc_creator

        puts $summaries.inspect
        summary_id = "1"
        puts "Create arc for which summary template? (enter ID)"
        $summaries.to_a.each {|s| puts "#{s["id"]} : #{s["summary"]}" }
        summary_id = STDIN.gets.chomp
        summary = $summaries.filter("id", summary_id.prepend("0", 5), nil).first
        puts "Creating arc for summary #{summary["summary"]}"
        puts "Here are the arcs for the selected summary:"
        $arcs.get_by_summary_id(summary_id).each{|a| puts "#{a["text"]}, order: #{a["order"]}"}
        puts "Input arc text:"
        arc = STDIN.gets.chomp
        puts "What order does this arc have? (number, can be comma seperated)"
        order = STDIN.gets.chomp
        puts "Adding arc: #{arc}, order: #{order}, for summary ID: #{summary_id}"
        $arcs.add(summary_id, order, arc)
        puts "done."

    end

    def start_scene_creator

        puts "What arc would you like to create a scene for? Enter the ID:"
        $summaries.to_a.each do |s|
            summary_id = s["id"]

            puts "Story: #{s["summary"]}"
            $arcs.get_by_summary_id(summary_id).each{|a| puts "    #{a.id} - #{a.text}, order: #{a.order}"}
        end
        arc_id = STDIN.gets.chomp
        arc = $arcs.get(arc_id)
        puts "Creating scene for arc #{arc_id}, '#{arc.text}'"
        puts "\n"
        puts "Existing scenes for selected arc:"
        $scenes.get_by_arc_id(arc_id).each{|s| puts " - #{s.time} #{s.setting} #{s.action}"}
        puts "\n"
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
        $scenes.add(arc_id, time, action, setting, order)
        puts "Scene created."

    end

end
