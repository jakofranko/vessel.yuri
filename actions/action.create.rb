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
        @docs = "Create new memories. Current commands: `create entity_type`"
        @summaries = nil
        @arcs = nil

    end

    def act q = nil

        raise "You must specify what you want to create..." unless !q.nil?

        if @summaries.nil? then @summaries = $summaries || Memory_Array.new('summaries', @host.path) end
        if @arcs.nil? then @arcs = $arcs || ArcMemory.new('arcs', @host.path) end

        args = q.split(' ')
        case args.first
        when 'entity_type'
            raise "You must at least specify the type of entity you are wanting to create e.g., `create entity_type Water`" unless args.length > 1
            create_entity_type(args[1..-1])
        when 'arc'
            start_arc_creator
        else
            puts "#{@host.name} cannot create #{args.first}"
        end

    end

    private

    def create_entity_type attrs = []

        @@entity_type_num_args.times do |i|
            next if attrs[i]
            attrs[i] = ''
        end

        new_file = File.new("#{@host.path}/memory/entity_types/#{attrs.first.downcase}.mh", "w")
        new_file.puts(@@entity_type_template % attrs)
        new_file.close

        puts @@entity_type_template % attrs

    end

    def start_arc_creator

        puts @summaries.inspect
        summary_id = "1"
        puts "Create arc for which summary template? (enter ID)"
        @summaries.to_a.each {|s| puts "#{s["id"]} : #{s["summary"]}" }
        summary_id = STDIN.gets.chomp
        summary = @summaries.filter("id", summary_id.prepend("0", 5), nil).first
        puts "Creating arc for summary #{summary["summary"]}"
        puts "Here are the arcs for the selected summary:"
        @arcs.get_by_summary_id(summary_id).each{|a| puts "#{a["text"]}, order: #{a["order"]}"}
        puts "Input arc text:"
        arc = STDIN.gets.chomp
        puts "What order does this arc have? (number, can be comma seperated)"
        order = STDIN.gets.chomp
        puts "Adding arc: #{arc}, order: #{order}, for summary ID: #{summary_id}"
        @arcs.add(summary_id, order, arc)
        puts "done."

    end

end
