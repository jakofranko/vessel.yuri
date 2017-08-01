require 'glossa'
require_relative './entity'

    def initialize data = nil

    def initialize params = {}

        @current_quest  = params[:current_quest] || nil
        @current_goal   = params[:current_goal]  || nil
        @location       = params[:location_id].nil? ? nil : $entities.get(params[:location_id])
        @language       = params[:language_id].nil? ? Glossa::Language.new(true) : $languages.get(params[:language_id])
        @name           = params[:name] || @language.make_name

    end

    def describe

        if @location.nil?
            return "#{@name} is roaming the void"
        else
            return "#{@name} is in #{@location.describe}"
        end

    end

end