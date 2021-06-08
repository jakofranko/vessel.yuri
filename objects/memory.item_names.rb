class ItemNameMemory < Memory_Hash

    PREFIX_CHANCE ||= 0.3
    SUFFIX_CHANCE ||= 0.2

    def rand

        items = self.to_h
        type = items["TYPE"].sample
        prefix = Random.rand < PREFIX_CHANCE ? items["PREFIX"].sample : '';
        suffix = Random.rand < SUFFIX_CHANCE ? items["SUFFIX"].sample : '';

        return "#{prefix} #{type} #{suffix}".strip

    end

end
