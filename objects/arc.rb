
class Arc

    ATTRS ||= [
        :id,
        :summary_id,
        :text,
        :order
    ]
    attr_accessor(*ATTRS)

    ##
    # Scenes will be generated from scene templates.
    # Settings and actions will be generated from text templates.
    # Time is a description of when the thing happened.
    # E.g., About mid-morning, while the merchants were selling their wares, a meteor fell from the sky.
    def initialize arc
        @id = arc["id"]
        @summary_id = arc["summary_id"]
        @text = arc["text"]
        @order = arc["order"]
    end

end
