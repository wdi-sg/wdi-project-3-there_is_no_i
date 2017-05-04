module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    protected
      def find_verified_user
        if current_user = User.find_by(id: cookies.signed[:user_id])
          current_user
          p "order assigned to #{current_user.name}"
        else
          current_user = User.new(name: 'Temp User')
          p "order assigned to #{current_user.name}"
        end
      end
  end
end
