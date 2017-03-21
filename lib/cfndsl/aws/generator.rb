require 'json'

def resources(spec)
  spec['ResourceTypes'] || spec[:ResourceTypes]
end

def properties(resource)
  resource['Properties'] || resource[:Properties]
end

def property_type(prop)
  types =  %w(PrimitiveItemType PrimitiveType ItemType)
  type = (types & prop.keys()).pop()

  if type.nil?
    if prop.key? 'Type'
      return prop['Type']
    end
  else
    value = prop[type]
    if prop.key? 'Type'
      return [value] if prop['Type'].downcase == 'list'
    end
    return value
  end
  raise 'Missing Property Type'
end

def property_types(resource)
  properties(resource).reduce({}) do |c, (name, info)|
    c[name] = property_type(info)
    c
  end
end

def generate(spec)
  resources(spec).reduce({}) do |c, (name, info)|
    c[name] = { Properties: property_types(info) }
    c
  end
end

def ordered(hash)
  hash.keys.sort.reduce({}) do |c, key|
    c[key] = hash[key]
    c
  end
end

def add_type(types, prop, prefix='')
  if prop.key? 'PrimitiveType'
    val = prop['PrimitiveType']
    types[:primitive].add val
  elsif prop.key? 'PrimitiveItemType'
    val = prop['PrimitiveItemType']
    types[:primitive].add val
  elsif prop.key? 'ItemType'
    val = prop['ItemType']
    p prefix, val
    types[:other].add(prefix + val)
  elsif prop.key? 'Type' and prop['Type'].downcase != 'list'
    val = prop['Type']
    types[:other].add(prefix + val)
  end
  types
end

def primitives(collected_types)
  raise 'no primitives' unless collected_types.key? :primitive
  collected_types[:primitive].reduce({}) do |c, type|
    c[type] = type
    c
  end
end

def others(collected_types, spec)

end

def add_types(types, resource, resource_name)
  properties(resource).each do |name, info|
    add_type(types, info, resource_name)
  end
  types
end

def collect_types(spec)
  resources(spec).reduce({primitive: Set.new, other: Set.new}) do |types, (name, info)|
    add_types(types, info, name + '.')
  end
end

def load_spec_file(filename)
  JSON.parse(File.read(filename))
end

def from_file(filename)
  ordered(generate(load_spec_file(filename)))
end
