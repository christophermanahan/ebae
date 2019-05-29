alias Ebae.{Accounts, Auction}

user_attrs = %{
  username: "username",
  credential: %{email: "email", password: "password"}
}

item_attrs = %{
  available: true,
  description: "some description",
  initial_price: "120.5",
  name: "some name",
}

{:ok, user} = Accounts.create_user(user_attrs)

Auction.create_item(Map.put(item_attrs, :user_id, user.id))
