# frozen_string_literal: true

class Role
  ROLES = {
    admin: 0,
    editor: 1,
    coordinator: 2,
    employee: 3,
    vendor: 4,
    customer: 5
  }.freeze

  attr_reader :id, :name

  def initialize(id, name)
    @id = id
    @name = name.to_sym
  end

  def self.all
    ROLES.map { |name, id| new(id, name) }
  end

  def self.find(name)
    id = ROLES[name.to_sym]
    new(id, name) if id
  end

  def self.find_by_key(key)
    find(key)
  end

  def self.default
    find(:employee)
  end

  def self.assignable
    all
  end

  def self.includes(role_key)
    []
  end

  def key
    name
  end

  def key_plus_included_by_keys
    [key]
  end

  def assignable?
    true
  end

  def manageable_roles
    []
  end

  def admin?
    key == :admin
  end

  def ==(other)
    return false unless other.is_a?(Role)

    id == other.id && name == other.name
  end

  ROLES.each do |name, id|
    define_singleton_method(name) do
      new(id, name)
    end
  end
end
