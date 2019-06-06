defmodule Ebae.EmailTest do
  use Ebae.DataCase

  alias Ebae.{Accounts, Auctions}

  defmodule MockDateTimePast do
    defdelegate compare(datetime1, datetime2), to: DateTime

    def utc_now do
      {:ok, now} = DateTime.from_naive(~N[2018-01-01 10:00:00], "Etc/UTC")
      now
    end
  end

  {:ok, start} = DateTime.from_naive(~N[2019-01-01 10:00:00], "Etc/UTC")
  {:ok, finish} = DateTime.from_naive(~N[2019-02-01 10:00:00], "Etc/UTC")
  @auction_attrs %{
    "start" => start,
    "finish" => finish,
    "description" => "some description",
    "initial_price" => "120.5",
    "name" => "some name"
  }

  @user_attrs %{
    "username" => "username",
    "credential" => %{email: "email", password: "password"}
  }

  test "won auction email" do
    {:ok, user} = Accounts.create_user(@user_attrs)
    {:ok, auction} =  Auctions.create_auction(Map.put(@auction_attrs, "user_id", user.id), MockDateTimePast)

    email = Ebae.Email.won_email(user, auction)

    assert email.to == user.credential.email
    assert email.from == "auction@ebae.shop"
    assert email.subject == "Hello auction winner!"
    assert email.text_body =~ "You have won auction #{auction.name}!"
  end
end

