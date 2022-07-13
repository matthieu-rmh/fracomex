defmodule Fracomex.Token do

  @account_verification_salt "account verification salt"
  def generate_new_account_token(user_id) do
    Phoenix.Token.sign(FracomexWeb.Endpoint, @account_verification_salt, user_id)
  end

  def verify_new_account_token(token) do
    max_age = 86_400
    Phoenix.Token.verify(FracomexWeb.Endpoint, @account_verification_salt, token, max_age: max_age)
  end
end
