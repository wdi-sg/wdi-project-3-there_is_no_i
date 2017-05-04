module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    protected
      def find_verified_user
        if current_user
          current_user    
        else
          current_user = User.new(name: 'Temp User')
        end
        p "order assigned to #{current_user.name}"
      end
  end
end
