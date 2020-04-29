class PostPolicy < ApplicationPolicy
  def edit?
    @user == "user1"
  end
end
