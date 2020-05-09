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
# TODO: Save/load stories
# TODO: Come up with templates for summaries
# TODO: ??? Create tool that will sift through the dictionary and allow me to sort words
#       by type. E.g., if I want to create a white-list of verbs for use in summaries,
#       have the tool give me all the verbs in the dictionary one at a time and I can say
#       'yes', or 'no'. If I want a list of objects for McGuffins, do the same thing with nouns.
#       Not sure if this is a good idea or it's better to just hardcode words
class Story

    # TODO: Move these to a memory
    ITEMS = [
        'Tetrahedron',
        'The One Ring',
        'The Infinity Gauntlet'
    ]

    NEW_WORLD_CHANCE = 0.01

    ATTRS = [
        :id,
        :tag_map,
        :summary,
        :summary_template,
        :current_scene,
        :arcs,
        :arc_scenes,
        :world
    ]
    attr_accessor(*ATTRS)
    def initialize id = nil, world_id = nil, summary = nil

        @id               = id
        @tag_map          = {}
        @summary_template = id ? get_summary_template : $summaries.sample
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

    def generate_summary

        summary = parse_tags(@summary_template["summary"].dup)

    end

    def generate_arcs

        by_order = {}
        used_arcs = []
        arcs = []

        summary_arcs = $arcs.get_by_summary_id(@summary_template["id"])

        # Sort all arcs by order they could occur
        summary_arcs.each do |arc|
            order = arc["order"].split(",")
            order.each do |o|
                if by_order[o].nil? then by_order[o] = [] end
                by_order[o].push(arc)
            end
        end

        # Select a single arc per order
        by_order.each do |order, arc_arr|
            arc_arr.shuffle.each do |arc|
                if !used_arcs.include? arc then
                    used_arcs.push(arc)

                    # Parse tags and push the re-formated arc into our final list
                    arc["text"] = parse_tags(arc["text"])
                    arcs.push(arc)
                    break
                else
                    next
                end
            end
        end

        return arcs
    end

    def generate_scenes

        scenes = []

        @arcs.each do |arc|
            scene = $scenes.get_by_arc_id(arc["id"]);
            if scene.length > 0 then
                scenes.push(scene)
            end
        end

        return scenes

    end

    def current_arc

        if @current_arc.nil? || @current_scenes.length == 0 then
            @current_arc = @arcs.shift
            @current_scenes = @current_arc.scenes
        end

        return @current_arc

    end

    def current_scene

        if @current_scene.nil? && @current_scenes.length != 0 then
            @current_scene = @current_scenes.shift
        end

        return @current_scene

    end

end
