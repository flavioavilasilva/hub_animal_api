class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Animal
    return unless user.present?

    return unless user.user_type == "ong"

    can :create, Animal
    can %i[update destroy], Animal, responsible_id: user.id
  end
end
