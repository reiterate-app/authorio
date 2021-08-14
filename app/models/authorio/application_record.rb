# frozen_string_literal: true

module Authorio
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
