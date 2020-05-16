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
require_relative 'objects/story'
require_relative 'objects/memory.entity'
require_relative 'objects/memory.item_names'
require_relative 'objects/memory.arc'
require_relative 'objects/memory.scene'
require_relative 'objects/memory.language'
require_relative 'objects/memory.story_entity'
require_relative 'objects/memory.story'
require_relative 'objects/memory.story_arc'

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
    $story_arcs = StoryArcMemory.new("stories/story_arcs", @host.path)

    # World Building memories
    $entities = EntityMemory.new("world_generation/entities", @host.path)
    $languages = LanguageMemory.new("world_generation/languages", @host.path)

    # Template memories
    $tags = Memory_Array.new("story_templates/tags", @host.path)
    $summaries = Memory_Array.new("story_templates/summaries", @host.path).to_a
    $arcs = ArcMemory.new("story_templates/arcs", @host.path)
    $scenes = SceneMemory.new("story_templates/scenes", @host.path)
    $story_entities = StoryEntityMemory.new("stories/story_entities", @host.path)
    $item_names = ItemNameMemory.new("story_templates/item_names", @host.path)

    # puts "--- NEW WORLD ---"
    # language = Glossa::Language.new(true)
    # language_id = $languages.add(language)
    # world = $archives.create(:world, {:name_self => true, :language_id => language_id, :language => language})
    # puts world.describe
    # $entities.add(world, true)

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
    # Create a new story
    story = Story.new

    # Save story
    story_id = $stories.add(story.world.ID, story.summary)
    story.id = story_id

    # Loop through all of the entities that have been generated
    # from the tags in the summaries, arcs and scenes, and save them.
    story.tag_map.each do |tag, entity|
        puts entity.inspect
        if entity.ID.nil? then
            entity_id = $entities.add(entity)
            entity.ID = entity_id
            $story_entities.add(entity, {:story_id => story_id})
        else
            # TODO: will only happen once stories can use existing story_entities
            # Only need to update the character entry since we are using an existing entity
            $story_entities.update(entity.id, { story_id: story_id})
        end
    end

    puts story.summary
    puts "The story will start with"

    # Save Arcs
    story.arcs.each_index do |i|
        arc = story.arcs[i]
        puts arc["text"]
        puts "and then"
        $story_arcs.add(arc, story_id, i)
    end



    # Save Scenes


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
