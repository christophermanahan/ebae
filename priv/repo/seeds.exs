alias Ebae.Accounts

user = %{
  username: "username",
  credential: %{email: "email", password: "password"}
}

Accounts.create_user(user)
