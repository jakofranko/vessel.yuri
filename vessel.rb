#!/bin/env ruby
# encoding: utf-8
require 'glossa'

$nataniev.require("action","tweet")

require_relative 'objects/entity'
require_relative 'objects/world'

class VesselYuri

  include Vessel

  def initialize id = 0

    super

    @name = "Yuri, Keeper of the Fire"
    @docs = "A pale (too pale?), grizzled man. Keeper of the Fire, Teller of the Stories."
    @site = "jakofranko.github.io/vessel.yuri"
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
    language = Glossa::Language.new
    world = World.new(language.make_name('world'))
    puts world.describe
    return "This is a test"

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