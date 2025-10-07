
class UserSerializer
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def as_json
    {
      id: user.id,
      login: user.login
    }
  end
end
