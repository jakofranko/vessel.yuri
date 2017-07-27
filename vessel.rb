#!/bin/env ruby
# encoding: utf-8
require 'glossa'

$nataniev.require("action","tweet")

require_relative 'objects/entity'
require_relative 'objects/world'
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
    # puts $entities.render
    # entity = $entities.get(q.to_i, true)
    # puts entity.describe

    language = Glossa::Language.new
    language.make_name('world')
    language.make_name('continent')
    language.make_name('continent')
    language.make_name('continent')
    language.make_name('sea')
    language.make_name('sea')
    language.make_name('sea')

    dict = LanguageMemory.new("languages", @host.path)
    dict.add(language)
    puts "---RENDER---"
    puts dict.render
    puts "---STRINGIFIED HASH---"
    dict.render.each do |key, value|
      puts dict.stringify_hash(key, value, 0)
    end


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