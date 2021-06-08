##
# A story object contains the logic for keeping track of its characters,
# summaries, story arcs, and scenes, and returning these objects
# for use mainly by the tell_story action.
#
# Summaries will be generated upon initialization, and will take the format:
# "Protagonist X must <verb> <something>[, but is opposed by antagonist Y]"
#
# Bare-minimum, a story requires a protagonist and a McGuffin.
# Given those two things, a series of arcs can be generated depending on the McGuffin.
#
# @tag_map: keeps track of the generated entity IDs that will be substituted in as the story is told.
#
# TODO: ??? Create tool that will sift through the dictionary and allow me to sort words
#       by type. E.g., if I want to create a white-list of verbs for use in summaries,
#       have the tool give me all the verbs in the dictionary one at a time and I can say
#       yes, or no. If I want a list of objects for McGuffins, do the same thing with nouns.
#       Not sure if this is a good idea or it's better to just hardcode words
class Story
    NEW_WORLD_CHANCE ||= 0.01

    ATTRS ||= [
        :id,
        :tag_map,
        :summary,
        :summary_template,
        :current_arc,
        :current_scene,
        :arcs,
        :arc_scenes,
        :world
    ]
    attr_accessor(*ATTRS)

    ##
    # The story_config param should contain the data in a row of the `stories` memory
    def initialize story_config = {}

        id = story_config["id"]
        world_id = story_config["world_id"]
        summary = story_config["summary"]

        @id               = id
        @tag_map          = {}
        @summary_template = id ? get_summary_template(id) : $summaries.to_a.sample
        @world            = world_id ? $entities.get(world_id) : pick_world
        # @characters       = id ? get_characters : pick_characters --> replaced by tag_map
        @summary          = summary || generate_summary
        @arcs             = id ? get_arcs : generate_arcs
        @arc_scenes       = id ? get_scenes : generate_scenes
        @current_arc      = nil
        @current_scene    = nil
        @current_scenes   = []

    end

    ##
    # Will handle creating and associating new entities to the story based on the tag
    def parse_tags str

        new_string = str.dup

        $tags.to_a.each do |t|
            next unless new_string

            tag = t["tag"]
            entity_type = t["entity"]
            string_match = new_string.match(tag)
            mapped_entity = @tag_map[tag]
            if string_match && mapped_entity.nil? then
                options = {}
                if entity_type == "Character" then
                    options[:name] = @world.LANG.make_name(tag.gsub(/\<\>/, ''))
                elsif entity_type == "Item" then
                    options[:name] = $item_names.rand
                else
                    options[:name_self] = true
                    options[:language] = @world.LANG # TODO: should use a character language instead
                end

                entity = $archives.create(entity_type.downcase.to_sym, options)
                @tag_map[tag] = entity
                new_string.gsub!(tag, entity.NAME)
            elsif string_match
                new_string.gsub!(tag, mapped_entity.NAME)
            end
        end

        return new_string

    end

    def pick_world

        worlds = $entities.filter("TYPE", "World", "Entity")
        chance = worlds.length > 0 ? NEW_WORLD_CHANCE : 1

        if rand < chance then
            new_language = Glossa::Language.new(true)
            language_id = $languages.add(new_language)
            world = $archives.create(:world, {:name_self => true, :language => new_language, :language_id => language_id})
            world.ID = $entities.add(world, true)
        else
            world = worlds.sample
        end

        return world

    end

    def get_summary_template id

        puts $summaries.inspect
        $summaries.to_a.select {|summary| summary["id"] === id}

    end

    def generate_summary

        summary = parse_tags(@summary_template["summary"].dup)

    end

    def generate_arcs

        used_arcs = []
        arcs = []

        summary_arcs = $arcs.get_by_summary_id(@summary_template["id"])

        # Sort all arcs by order they could occur
        by_order = get_by_order(summary_arcs)

        # Select a single arc per order
        by_order.each do |order, arc_arr|
            arc_arr.shuffle.each do |arc|
                if !used_arcs.include? arc then
                    used_arcs.push(arc)

                    # Parse tags and push the re-formated arc into our final list
                    arc.text = parse_tags(arc.text)
                    arcs.push(arc)
                    break
                else
                    next
                end
            end
        end

        return arcs
    end

    ##
    # Generate all of the scenes belonging to each story arc
    # returning a map of scenes for each story arc where the
    # keys are the arc IDs and the values are the ordered array of scenes.
    def generate_scenes

        scenes = {}

        @arcs.each do |arc|
            arc_scenes = $scenes.get_by_arc_id(arc.id);
            by_order = get_by_order(arc_scenes)
            used_scenes = []

            by_order.each do |order, scene_arr|
                scene_arr.shuffle.each do |scene|
                    if !used_scenes.include? scene then
                        used_scenes.push(scene)
                        formatted_scene = scene.dup

                        # Parse tags and push the re-formated scene into our final list
                        formatted_scene.time = parse_tags(scene.time)
                        formatted_scene.setting = parse_tags(scene.setting)
                        formatted_scene.action = parse_tags(scene.action)
                        formatted_scene.order = order

                        if !scenes[arc.id] then scenes[arc.id] = [] end
                        scenes[arc.id].push(formatted_scene)
                        scenes[arc.id].sort_by(&:order)
                        break
                    else
                        next
                    end
                end
            end
        end

        return scenes

    end

    def get_arcs

        $story_arcs.get_by_story_id(@id)

    end

    def get_scenes

        raise "The @arcs variable has to be set and must be an array" unless @arcs.kind_of?(Array)

        scenes = []
        @arcs.each do |arc|
            scenes.concat $story_arc_scenes.get_by_arc_id(arc["ID"])
        end

        scenes

    end

    def current_arc

        if @current_arc.nil? || @current_scenes.length == 0 then
            @current_arc = @arcs.shift

            if @scenes.nil? || @scenes.length == 0 then
                raise 'There are no scenes for the selected story.'\
                    ' You need to make sure there are scene templates'\
                    ' written out for all the arc templates in your given story template.'\
                    ' Then, you will need to delete this story and generate a new one.'
            else
                @current_scenes = @scenes.select {|scene| scene["arc_id"] == @current_arc["ID"] }
            end
        end

        return @current_arc

    end

    def current_scene

        if @current_scene.nil? && @current_scenes.length != 0 then
            @current_scene = @current_scenes.shift
        end

        return @current_scene

    end

    private

    ##
    # Expects an unordered list of items that each have
    # a property called "order", which is a comma delinated
    # list of possible order numbers that item could appear in
    def get_by_order unordered_list
        by_order = {}
        unordered_list.each do |item|
            order = item.order.split(",")
            order.each do |o|
                if by_order[o].nil? then by_order[o] = [] end
                by_order[o].push(item)
            end
        end

        return by_order
    end
end
