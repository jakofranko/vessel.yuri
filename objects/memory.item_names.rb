# Memory for item names, via Nataniev's memory system
class ItemNameMemory < Memory_Hash

  PREFIX_CHANCE ||= 0.3
  SUFFIX_CHANCE ||= 0.2

  def rand

    items = to_h
    type = items['TYPE'].sample
    prefix = Random.rand < PREFIX_CHANCE ? items['PREFIX'].sample : ''
    suffix = Random.rand < SUFFIX_CHANCE ? items['SUFFIX'].sample : ''

    "#{prefix} #{type} #{suffix}".strip

  end

end
