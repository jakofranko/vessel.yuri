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
# TODO: Save/load stories
# TODO: Come up with templates for summaries
# TODO: ??? Create tool that will sift through the dictionary and allow me to sort words
#       by type. E.g., if I want to create a white-list of verbs for use in summaries,
#       have the tool give me all the verbs in the dictionary one at a time and I can say
#       'yes', or 'no'. If I want a list of objects for McGuffins, do the same thing with nouns.
#       Not sure if this is a good idea or it's better to just hardcode words
# TODO: Create arc templates given a summary type
class Story

    ITEMS = [
        'Tetrahedron',
        'The One Ring',
        'The Infinity Gauntlet'
    ]

    attr_accessor :summary, :summary_template, :characters, :current_arc, :current_scene
    def initialize

        @characters       = pick_characters
        @summary_template = $summaries.sample
        @summary          = generate_summary
        @arcs             = generate_arcs
        @current_arc      = get_current_arc
        @current_scene    = get_current_scene # Does this live here, or in the Arc class?

    end

    def pick_characters

        {
            :protagonist => Character.new,
            :antagonist  => Character.new
        }

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

        by_order = {}
        summary_arcs = $arcs.get_by_summary_id(@summary_template["id"])
        summary_arcs.each do |arc|
            order = arc.order.split(",")
            order.each do |o|
                if by_order[o].nil? then by_order[o] = [] end
                by_order[o].push(arc)
            end
        end

        puts by_order.inspect

    end

    def get_current_arc

        return false

    end

    def get_current_scene

        return false

    end

end
