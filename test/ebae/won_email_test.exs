defmodule Ebae.EmailTest do
  use Ebae.DataCase

  alias Ebae.Accounts

  @user_attrs %{
    "username" => "username",
    "credential" => %{email: "email", password: "password"}
  }

  test "won auction email" do
    {:ok, user} = Accounts.create_user(@user_attrs)
    auction_name = "auction"

    email = Ebae.Email.won_email(user, auction_name)

    assert email.to == user.credential.email
    assert email.from == "auction@ebae.shop"
    assert email.subject == "Hello auction winner!"
    assert email.text_body =~ "You have won auction #{auction_name}!"
  end
end

