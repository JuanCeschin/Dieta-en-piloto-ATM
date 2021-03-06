class ItemPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end

  end

  def new?
    user
  end

  def create?
    new?
  end

  def edit?
    new?
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end
end
