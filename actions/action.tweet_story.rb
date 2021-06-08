$nataniev.require("action","tweet")

class ActionTweet

    def initialize q = nil

      super

      @name = "Tweet Story"
      @docs = "Used to tweet the current story payload"

    end

    def account

        return "yuriofthefire"

    end

    def payload

        return ActionTest.new(@host).act

    end

end
