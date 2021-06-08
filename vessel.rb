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
require_relative 'objects/memory.story_arc_scene'

class VesselYuri

  include Vessel

  def initialize id = 0

    super

    @name = "Yuri, Keeper of the Fire"
    @docs = "A pale (too pale?), grizzled man. Keeper of the Fire, Teller of the Stories."
    @site = "https://jakofranko.github.io/vessel.yuri"
    @path = File.expand_path(File.join(File.dirname(__FILE__), "/"))

    install(:primary, :create)
    install(:primary, :story)
    install(:primary, :listen)
    install(:primary, :test)
    install(:primary, :tweet)

    install(:generic, :document)
    install(:generic, :help)


  end

end
