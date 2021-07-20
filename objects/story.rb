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

                    # Convert to a hash when populating arcs array,
                    # since this is ultimately the form it will take
                    # when this is populated by the `get_arcs` method.
                    arcs.push(arc.to_h)
                    break
                else
                    next
                end
            end
        end

        # Note that the arcs will not have been saved yet,
        # and so don't have the proper IDs. Currently the IDs
        # are their *template* IDs.
        return arcs
    end

    ##
    # Generate all of the scenes belonging to each story arc
    # returning a map of scenes for each story arc where the
    # keys are the arc IDs and the values are the ordered array of scenes.
    def generate_scenes

        scenes = {}

        @arcs.each do |arc|
            # Note, these are being fetched the the arc's *template* ID
            arc_scenes = $scenes.get_by_arc_id(arc["ID"]);
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

                        if !scenes[arc["ID"]] then scenes[arc["ID"]] = [] end
                        scenes[arc["ID"]].push(formatted_scene)
                        scenes[arc["ID"]].sort_by(&:order)
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

        scenes = {}
        @arcs.each do |arc|
            scenes[arc["ID"]] = $story_arc_scenes.get_by_arc_id(arc["ID"])
        end

        scenes

    end

    def initialize_current_scenes
        if @arc_scenes.nil? || @arc_scenes[@current_arc["ID"]].nil? || @arc_scenes[@current_arc["ID"]].length == 0 then
            # We'll use the current arc's text and shift to the next arc
            @current_scenes = [@current_arc["TEXT"]]
        else
            @current_scenes = @arc_scenes[@current_arc["ID"]]
        end
    end

    def get_next_arc
        @current_arc = @arcs.shift
        if @current_arc.nil? then
            puts "The story is done! Setting current story to NULL"
            story = $current_story
            story.render = {"CURRENT_STORY" => "NULL"}
            $current_story.save
        else
            initialize_current_scenes
            @current_scene = @current_scenes.shift
        end
    end

    def get_current_arc arc_id = nil

        if arc_id.nil? && $current_story then
            # Let's search the $current_story object for one
            cs = $current_story.to_h
            arc_id = cs["CURRENT_STORY"] ? cs["CURRENT_STORY"]["CURRENT_ARC"] : nil
        end

        if @current_arc.nil? && arc_id.nil? == false then
            # This should work to discard already used arcs, since
            # the @arcs attribute should come sorted by order
            # puts "shifting through arcs"
            while @current_arc == nil || @current_arc["ID"] != arc_id
                @current_arc = @arcs.shift
            end
        elsif @current_arc.nil? || @current_scenes.length == 0 then
            # puts "getting next arc"
            @current_arc = @arcs.shift
        end

        initialize_current_scenes

        return @current_arc

    end

    def get_current_scene

        return @current_scene unless @current_scene.nil?

        # two scenarios need to be handled, or maybe 3:
        # 1. The current scene is nil, but there is another scene in the current_scenes array
        # 2. A new story has been generated and there is nothing in the current_story memory
        # 3. A LAST_SCENE exists, but there is no ID because it was just the arc text (an arc was selected that has no coresponding scene templates)
        # 4. A LAST_SCENE exists, and it has an ID, and so the next scene needs to be determined based on this ID
        cs = $current_story.to_h["CURRENT_STORY"]
        last_scene = cs["LAST_SCENE"] || {}
        last_scene_id = last_scene["ID"]
        last_scene_order = last_scene["ORDER"]
        # puts last_scene_id.inspect
        # puts @arc_scenes
        # puts @current_scenes.inspect

        # The first case is that the arcs have just been initialized, so pull the first scene
        if last_scene_id.nil? && @current_scenes.length != 0 then
            puts "shifting to the next scene with current scenes and no scene ID"
            @current_scene = @current_scenes.shift
        else
            # Otherwise, we need to figure out what the next scene will be given the last scene
            # The last scene might have just been arc text
            if last_scene_id.nil?
                puts "Last scene didn't have an ID, so shifting to next arc"
                get_next_arc
            else
                # Find the next scene
                # Search the current arc's scenes
                @arc_scenes[cs["CURRENT_ARC"]].each do |arc_scene|
                    if arc_scene.order > last_scene_order then
                        puts "Found next scene!"
                        @current_scene = arc_scene
                        break
                    end
                end

                # If it didn't find a higher order scene in the current arc, time to shift arcs
                if @current_scene.nil? then
                    puts "higher order scene not found, shifting to next arc"
                    get_next_arc
                end
            end
        end

        # Check if the current_scenes is empty now, and refill
        if @current_scenes.length == 0 then
            if @arcs.length == 0
                puts "The story is done! Setting current story to NULL"
                story = $current_story
                story.render = {"CURRENT_STORY" => "NULL"}
                $current_story.save
            else
                puts "Scenes are empty, moving to next arc"
                @current_arc = @arcs.shift
                initialize_current_scenes
            end
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
