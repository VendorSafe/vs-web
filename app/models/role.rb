# frozen_string_literal: true

class Role < ApplicationRecord
  include Roles::Support

  def self.employee
    find('employee')
  end

  def self.vendor
    find('vendor')
  end

  def self.coordinator
    find('coordinator')
  end

end
