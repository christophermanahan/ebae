alias Ebae.{Accounts, Auctions}

user_attrs = %{
  username: "username",
  credential: %{email: "email", password: "password"}
}

auction_attrs = %{
  available: true,
  description: "some description",
  initial_price: "120.5",
  name: "some name"
}

{:ok, user} = Accounts.create_user(user_attrs)

Auctions.create_auction(Map.put(auction_attrs, :user_id, user.id))
