require_relative './character'

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
        :summary,
        :summary_template,
        :characters,
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
        @characters       = id ? get_characters : pick_characters
        @world            = world_id ? $entities.get(world_id) : pick_world
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

        $tags.to_a.each do |t|
            if str.match(t.tag) && !@tag_map[t.tag].nil? then
                new_id = Object.const_get(t.entity).new
                # @tag_map[t.tag] = new entity ID
            end
        end

    end

    def pick_characters

        {
            :protagonist => Character.new,
            :antagonist  => Character.new
        }

    end

    def pick_world

        if rand < NEW_WORLD_CHANCE then
            world = $archives.create(:world, {:name_self => true, :language => Glossa::Language.new(true)})
            # puts world.inspect
            @world = world
            puts 'making a new world'
            puts @world
            @world.ID = $entities.add(world)
        else
            puts 'getting an existing world'
            worlds = $entities.filter("TYPE", "World", "Entity")
            @world = worlds.sample
        end

        return @world

    end

    def generate_summary

        summary = @summary_template["summary"].dup

        # Substitute out the wildcards for actual things
        summary.gsub!('<item>', ITEMS.sample)
        summary.gsub!('<protagonist>', @characters[:protagonist].name)
        summary.gsub!('<antagonist>', @characters[:antagonist].name)

        return summary

    end

    def generate_arcs

        arcs = []
        by_order = {}
        used_arcs = []

        summary_arcs = $arcs.get_by_summary_id(@summary_template["id"])
        summary_arcs.each do |arc|
            order = arc["order"].split(",")
            order.each do |o|
                if by_order[o].nil? then by_order[o] = [] end
                by_order[o].push(arc)
            end
        end

        by_order.each do |order, arc_arr|
            arc_arr.shuffle.each do |arc|
                if !used_arcs.include? arc then
                    arcs.push(arc)
                    used_arcs.push(arc)
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
