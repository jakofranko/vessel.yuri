require 'glossa'
require_relative './entity'

##
# Character differ from other entities, in that they will care less about how they are described,
# and more about things like  their current 'goal', 'quest', and attributes that will dictate
# a proclivity to accomplishing goals a certain way. They do need a way to be described, and
# could take advantage of the entity class to describe themselves?
# TODO: loading/saving
# TODO: pick new quest
# TODO: pick new goal
class Character # < Entity

    ATTRS = [
        :id,
        :name,
        :language,
        :story_id,
        :language_id,
        :location,
        :current_quest,
        :current_goal
    ]
    attr_accessor(*ATTRS)

    def initialize params = {}

        @character_id   = params[:id] || nil
        @current_quest  = params[:current_quest] || nil
        @current_goal   = params[:current_goal]  || nil
        @location       = params[:location_id].nil? ? nil : $entities.get(params[:location_id])
        @language_id    = params[:language_id]
        @story_id       = params[:story_id]
        @language       = params[:language_id].nil? ? Glossa::Language.new(true) : $languages.get(params[:language_id].to_i)
        @name           = params[:name] || @language.make_name

    end

    def describe

        if @location.nil?
            return "#{@name} is roaming the void"
        else
            return "#{@name} is in #{@location.describe}"
        end

    end

    def to_h
        h = {}
        ATTRS.each do |attr|
            h[attr] = instance_variable_get("@#{attr.to_s}")
        end

        return h
    end

end
