#!/bin/env ruby
# encoding: utf-8
require 'glossa'

require_relative 'objects/archives'
require_relative 'objects/entity'
require_relative 'objects/story'
require_relative 'objects/memory.current_story'
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
