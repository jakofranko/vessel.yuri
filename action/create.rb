class ActionCreate

    include Action

    @@entity_type_template = "" \
        "TYPE : %s\n" \
        "CMAX : %s\n\n" \
        "ADJV\n\s\s%s\n\n" \
        "VERB\n\s\s%s\n\n" \
        "ADVB\n\s\s%s\n\n" \
        "CTPS\n\s\s%s\n\n" \
        "CPRP\n\s\s%s\n\n" \


    def initialize q = nil

        super

        @name = "Create"
        @docs = "Create a new memories. Current commands: `create entity_type`"

    end

    def act q = nil

        args = q.split(' ')
        case args.first
        when 'entity_type'
            raise "You must at least specify the type of entity you are wanting to create e.g., `create entity_type Water`" unless args.length > 1
            create_entity_type(args[1..-1])
        else
            puts "#{@host.name} cannot create #{args.first}"
        end

    end

    private

    def create_entity_type attrs = []

        new_file = File.new("#{attrs.first.downcase}.mh", "w")
        new_file.puts(@@entity_type_template % attrs)
        new_file.close

        puts @@entity_type_template % attrs

    end

end
