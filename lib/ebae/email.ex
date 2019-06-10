defmodule Ebae.Email do
  import Bamboo.Email
  import Bamboo.Phoenix

  def won_email(user, auction_name) do
    new_email(
      to: user.credential.email,
      from: "auction@ebae.shop",
      subject: "Hello auction winner!",
      text_body:  "You have won auction #{auction_name}!"
    )
  end
end
