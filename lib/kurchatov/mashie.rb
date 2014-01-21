class Mashie < Hash

  def initialize(source_hash = nil, default = nil, &blk)
    deep_update(source_hash) if source_hash
    default ? super(default) : super(&blk)
  end

  class << self; alias [] new; end

  def id #:nodoc:
    self["id"]
  end

  def type #:nodoc:
    self["type"]
  end

  alias_method :regular_reader, :[]
  alias_method :regular_writer, :[]=

  def custom_reader(key)
    value = regular_reader(convert_key(key))
    yield value if block_given?
    value
  end

  def custom_writer(key,value) #:nodoc:
    regular_writer(convert_key(key), convert_value(value))
  end

  alias_method :[], :custom_reader
  alias_method :[]=, :custom_writer

  def initializing_reader(key)
    ck = convert_key(key)
    regular_writer(ck, self.class.new) unless key?(ck)
    regular_reader(ck)
  end

  def underbang_reader(key)
    ck = convert_key(key)
    if key?(ck)
      regular_reader(ck)
    else
      self.class.new
    end
  end

  def fetch(key, *args)
    super(convert_key(key), *args)
  end

  def delete(key)
    super(convert_key(key))
  end

  alias_method :regular_dup, :dup
  # Duplicates the current mash as a new mash.
  def dup
    self.class.new(self, self.default)
  end

  def key?(key)
    super(convert_key(key))
  end
  alias_method :has_key?, :key?
  alias_method :include?, :key?
  alias_method :member?, :key?

  def deep_merge(other_hash, &blk)
    dup.deep_update(other_hash, &blk)
  end
  alias_method :merge, :deep_merge

  def deep_update(other_hash, &blk)
    other_hash.each_pair do |k,v|
      key = convert_key(k)
      if regular_reader(key).is_a?(Mash) and v.is_a?(::Hash)
        custom_reader(key).deep_update(v, &blk)
      else
        value = convert_value(v, true)
        value = blk.call(key, self[k], value) if blk
        custom_writer(key, value)
      end
    end
    self
  end
  alias_method :deep_merge!, :deep_update
  alias_method :update, :deep_update
  alias_method :merge!, :update

  def shallow_merge(other_hash)
    dup.shallow_update(other_hash)
  end

  def shallow_update(other_hash)
    other_hash.each_pair do |k,v|
      regular_writer(convert_key(k), convert_value(v, true))
    end
    self
  end

  def replace(other_hash)
    (keys - other_hash.keys).each { |key| delete(key) }
    other_hash.each { |key, value| self[key] = value }
    self
  end

  def respond_to?(method_name, include_private=false)
    return true if key?(method_name) || method_name.to_s.slice(/[=?!_]\Z/)
    super
  end

  def method_missing(method_name, *args, &blk)
    return self.[](method_name, &blk) if key?(method_name)
    match = method_name.to_s.match(/(.*?)([?=!_]?)$/)
    case match[2]
    when "="
      self[match[1]] = args.first
    when "?"
      !!self[match[1]]
    when "!"
      initializing_reader(match[1])
    when "_"
      underbang_reader(match[1])
    else
      default(method_name, *args, &blk)
    end
  end

  protected

  def convert_key(key) #:nodoc:
    key.to_s
  end

  def convert_value(val, duping=false) #:nodoc:
    case val
    when self.class
      val.dup
    when Hash
      duping ? val.dup : val
    when ::Hash
      val = val.dup if duping
      self.class.new(val)
    when Array
      val.collect{ |e| convert_value(e) }
    else
      val
    end
  end
end
