require 'repository'
require 'models/signup'
require 'state_machine'
require 'interactors/check_user_permissions'

##
# The four signup actions are:
#
# accept    :: Raid Leader can accept a character
# unaccept  :: Raid Leader can move a character back to available from accepted
# enqueue   :: Character owner can move said character back to available
# cancel    :: Character owner can move said character into cancelled
#
##
class UpdateSignup

  attr_accessor :current_user, :current_guild

  def initialize(current_user, current_guild)
    @current_user = current_user
    @current_guild = current_guild
  end

  ##
  # Returns a list of all available actions the current user can take
  # on the given signup. In most cases will only be one or two actions
  ##
  def available_actions(signup)
    initialize_processor_and_permissions signup

    @processor.available_actions
  end

  ##
  # +action+ can be one of :accept, :unaccept, :enqueue, or :cancel
  ##
  def run(signup, action)
    initialize_processor_and_permissions signup

    @processor.send action
    signup.acceptance_status = @processor.new_status

    Repository.for(Signup).save signup
  end

  def initialize_processor_and_permissions(signup)
    @permissions = CheckUserPermissions.new @current_user, @current_guild
    @processor = StateProcessor.new @current_user, signup, @permissions
  end

  class StateProcessor
    def initialize(current_user, signup, permissions)
      super()

      @signup = signup
      @current_user = current_user
      self.signup_status = @signup.acceptance_status
      @permissions = permissions
    end

    def new_status
      self.signup_status.to_sym
    end

    def available_actions
      [
        (:cancel   if can_cancel_signup?),
        (:enqueue  if can_enqueue_signup?),
        (:unaccept if can_unaccept_signup?),
        (:accept   if can_accept_signup?)
      ].compact
    end

    def can_accept_signup?
      @signup.available? && @permissions.allowed?(:manage_signups)
    end

    def can_unaccept_signup?
      @signup.accepted? && @permissions.allowed?(:manage_signups)
    end

    def can_enqueue_signup?
      @signup.cancelled? && @current_user == @signup.user
    end

    def can_cancel_signup?
      !@signup.cancelled? && @current_user == @signup.user
    end

    state_machine :signup_status do
      state :accepted
      state :available
      state :cancelled

      event :accept do
        transition :available => :accepted, :if => :can_accept_signup?
      end

      event :unaccept do
        transition :accepted => :available, :if => :can_unaccept_signup?
      end

      event :enqueue do
        transition :cancelled => :available, :if => :can_enqueue_signup?
      end

      event :cancel do
        transition :accepted => :cancelled, :if => :can_cancel_signup?
        transition :available => :cancelled, :if => :can_cancel_signup?
      end
    end
  end

end
