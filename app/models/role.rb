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

  ROLE_INCLUDES = {
    admin: %i[editor coordinator employee vendor],
    editor: [:employee],
    coordinator: [:employee],
    vendor: [],
    employee: [],
    customer: []
  }.freeze

  MANAGEABLE_ROLES = {
    admin: %i[admin editor coordinator employee vendor],
    editor: %i[editor employee],
    coordinator: [:employee],
    vendor: [],
    employee: [],
    customer: []
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
    included_roles = ROLE_INCLUDES[role_key.to_sym] || []
    included_roles.map { |role| find(role) }
  end

  # Explicitly define class methods for each role
  def self.admin
    new(ROLES[:admin], :admin)
  end

  def self.editor
    new(ROLES[:editor], :editor)
  end

  def self.coordinator
    new(ROLES[:coordinator], :coordinator)
  end

  def self.employee
    new(ROLES[:employee], :employee)
  end

  def self.vendor
    new(ROLES[:vendor], :vendor)
  end

  def self.customer
    new(ROLES[:customer], :customer)
  end

  def key
    name
  end

  def key_plus_included_by_keys
    included_by = ROLE_INCLUDES.select { |_, includes| includes.include?(key) }.keys
    [key] + included_by
  end

  def assignable?
    true
  end

  def manageable_roles
    (MANAGEABLE_ROLES[key] || []).map { |role_key| Role.find(role_key) }
  end

  def admin?
    key == :admin
  end

  def vendor?
    key == :vendor
  end

  def employee?
    key == :employee
  end

  def coordinator?
    key == :coordinator
  end

  def editor?
    key == :editor
  end

  def customer?
    key == :customer
  end

  def ==(other)
    return false unless other.is_a?(Role)

    id == other.id && name == other.name
  end
end
