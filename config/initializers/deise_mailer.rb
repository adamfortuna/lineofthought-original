module Devise
  module Models
    module Confirmable
      handle_asynchronously :send_confirmation_instructions, :priority => -5
    end

    module Recoverable
      handle_asynchronously :send_reset_password_instructions, :priority => -5
    end

    module Lockable
      handle_asynchronously :send_unlock_instructions, :priority => -5
    end
  end
end