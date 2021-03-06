class DailyTargetPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def create?
    return true
  end

  def show?
    record.user == user
  end

  def update?
    record.user == user
  end
end
