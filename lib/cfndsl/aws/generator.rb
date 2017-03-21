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

def generate_resources(spec)
  resources(spec).reduce({}) do |c, (name, info)|
    c[name] = { 'Properties' => property_types(info) }
    c
  end
end

def ordered(hash, start_hash={})
  hash.keys.sort.reduce(start_hash) do |c, key|
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

def spec_to_cfndsl_type_name(name)
  parts = name.split('.')
  raise 'Weird PropertyType name: ' + name if parts.length > 2
  parts[-1]
end

def has_method?(o, method)
  o.methods.include? method.to_sym
end

def collect_primitives(primitives, info)
  properties(info).each do |name, prop|
    if has_method?(prop, :key?)
      if prop.key? 'PrimitiveType'
        primitives.add prop['PrimitiveType']
      elsif prop.key? 'PrimitiveItemType'
        primitives.add prop['PrimitiveItemType']
      end
    else
      p prop
      raise 'No key? method'
    end
  end
  primitives
end

def primitives_to_hash(primitives)
  primitives.reduce({}) do |c, type|
    c[type] = type
    c
  end
end

def generate_types(spec)
  primitives = Set.new
  types = spec['PropertyTypes'].reduce({}) do |c, (name, info)|
    name = spec_to_cfndsl_type_name(name)
    collect_primitives(primitives, info)
    c[name] = property_types(info)
    c
  end
  ordered(types, primitives_to_hash(primitives))
end

def items_with_keys_like(hash, like_what)
  hash.select do |key, value|
    key.to_s.match(like_what)
  end
end

def generate(spec)
  { 'Resources' => ordered(generate_resources(spec)),
    'Types' => ordered(generate_types(spec)) }
end

def load_spec_file(filename)
  JSON.parse(File.read(filename))
end

def from_file(filename)
  generate(load_spec_file(filename))
end
