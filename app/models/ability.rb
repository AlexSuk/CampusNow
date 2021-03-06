class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:

      user ||= User.new # guest user (not logged in)
      can :read, :all

      if user.is_admin?

        can :manage, :all
        can :read, :all
        #these two below are the ones that allow us to use the admin dashboard where they should be
        can :access, :rails_admin
        can :dashboard
      elsif user.can_host?
        can :read, :all
        can :create, Event
				#this allows a host to do anything to an event that belongs to them
        can :manage, Event do |event|
          event.host == user
        end
				#this allows a host to do anything to their own profile
        can :manage, User do |u|
          u == user
        end
      else
        can :read, :all
				#this allows a user to do anything to their own profile
        can :manage, User do |u|
          u == user
        end
      end
  end
end
