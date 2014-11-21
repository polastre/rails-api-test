module Validate
  class Distance
    include ActiveModel::Validations

    attr_accessor :first_name, :last_name, :ip_address

    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :ip_address, presence: true
  
    def initialize(params={})
      @first_name = params[:first_name]
      @last_name = params[:last_name]
      @ip_address = params[:ip_address]
      ActionController::Parameters.new(params)
    end

  end
end
