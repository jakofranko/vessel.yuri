#!/bin/env ruby
# encoding: utf-8
require 'glossa'

$nataniev.require("action","tweet")

# TODO: Characters -- probably a type of entity (for generated descriptions), but should be saved in their own memory, since characters will need to keep track of where they are (location), goals, current activities etc.
# TODO: Goals -- these will be templates for generating scenes
# TODO: Scenes -- these will be the machines that spit out text for our stories
# TODO: tell_story action, which will manage setting, characters, goals, scenes, quests, what is current, generating story chunks from scenes, creating the twitter payload, tweeting, and loading/saving all of these things.
# TODO: Separation of data and functionality. Instead of entity objects, they should be memories

require_relative 'objects/archives'
require_relative 'objects/entity'
require_relative 'objects/character'
require_relative 'objects/story'
require_relative 'objects/memory.entity'
require_relative 'objects/memory.arc'
require_relative 'objects/memory.scene'
require_relative 'objects/memory.language'
require_relative 'objects/memory.character'
require_relative 'objects/memory.story'

class VesselYuri

  include Vessel

  def initialize id = 0

    super

    @name = "Yuri, Keeper of the Fire"
    @docs = "A pale (too pale?), grizzled man. Keeper of the Fire, Teller of the Stories."
    @site = "https://jakofranko.github.io/vessel.yuri"
    @path = File.expand_path(File.join(File.dirname(__FILE__), "/"))

    install(:primary, :create)

    install(:generic, :document)
    install(:generic, :help)

    install(:default, :test)
    install(:default, :tweet)

  end

end

class ActionTest

  include Action

  def initialize q = nil

    super

    @name = "Test"
    @docs = "For testing output (currently for testing the tweet payload without actually sending it)"

  end

  def act q = nil

    q = q == "" ? nil : q

    $archives = Archives.new(@host)
    $stories = StoryMemory.new("stories/stories", @host.path)

    # Template memories
    $summaries = Memory_Array.new("story_templates/summaries", @host.path).to_a
    $arcs = ArcMemory.new("story_templates/arcs", @host.path)
    $scenes = SceneMemory.new("story_templates/scenes", @host.path)
    $entities = EntityMemory.new("world_generation/entities", @host.path)
    $languages = LanguageMemory.new("world_generation/languages", @host.path)
    $characters = CharacterMemory.new("stories/characters", @host.path)

    # puts "--- NEW WORLD ---"
    # world = $archives.create(:world, {:name_self => true, :language => Glossa::Language.new(true)})
    # puts world.describe
    #
    # puts "\n--- ENTITY FROM MEMORY ---"
    # entity = $entities.get(2)
    # puts entity.describe
    #
    # puts "\n--- ENTITY FROM MEMORY W/ CHILDREN ---"
    # continent = $entities.get(7, true) # with children
    # puts continent.describe

    # puts "---RENDER---"
    # puts $languages.render

    # puts "--- GOT LANG ---"
    # lang = $languages.get q
    # puts lang.make_name("strange")
    # $languages.save

    # $languages.update(q, lang)

    # character = Character.new({:language_id => q, :location_id => 13})
    # puts character.describe
    # $characters.add(character)

    # puts "\n--- ARCS ---"
    # puts $arcs.inspect
    #
    # puts "\n--- SCENES ---"
    # puts $scenes.inspect

    puts "\n--- NEW STORY ---"
    # Create a new story, and then save the results
    story = Story.new
    story_id = $stories.add(story.world.ID, story.summary)
    story.id = story_id
    story.characters.each do |type, character|
        if !character.id then
            character.story_id = story_id
            $characters.add(character)
        else
            # TODO: will only happen once stories can use existing characters
            $characters.update(character.id, { story_id: story_id})
        end
    end

    # Inspect story
    puts story.inspect
    # puts story.summary_template
    # puts story.summary
    # puts story.arcs.inspect
    # puts "\n--- STORY SCENES ---"
    # story.arc_scenes.each do |arc_scenes|
    #     arc_scenes.each {|scene| puts scene.describe}
    # end

    return ""

  end

end

class ActionTweet

  def account

    return "yuriofthefire"

  end

  def payload

    return ActionTest.new(@host).act

  end

end
