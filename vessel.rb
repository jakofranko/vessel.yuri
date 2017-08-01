#!/bin/env ruby
# encoding: utf-8
require 'glossa'

$nataniev.require("action","tweet")

# TODO: Characters -- probably a type of entity (for generated descriptions), but should be saved in their own memory, since characters will need to keep track of where they are (location), goals, current activities etc.
# TODO: Goals -- these will be templates for generating scenes
require_relative 'objects/entity'
require_relative 'objects/world'
require_relative 'objects/character'
require_relative 'objects/memory.entity'
require_relative 'objects/memory.language'

class VesselYuri

  include Vessel

  def initialize id = 0

    super

    @name = "Yuri, Keeper of the Fire"
    @docs = "A pale (too pale?), grizzled man. Keeper of the Fire, Teller of the Stories."
    @site = "https://jakofranko.github.io/vessel.yuri"
    @path = File.expand_path(File.join(File.dirname(__FILE__), "/"))

    install(:generic,:document)
    install(:generic,:help)

    install(:default,:test)
    install(:default,:tweet)
    
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

    $entities = EntityMemory.new('entities', @host.path)
    $languages = LanguageMemory.new("languages", @host.path)

    # puts "---RENDER---"
    # puts $languages.render

    puts "--- GOT LANG ---"
    lang = $languages.get q
    puts lang.make_name("strange")
    $languages.save

    # $languages.update(q, lang)

    # world = World.new({:name => language.make_name('world')})
    # puts world.describe

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