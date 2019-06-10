defmodule Ebae.SchedulerTest do
  use Ebae.DataCase

  alias Ebae.{Scheduler, Accounts, Auctions}

  defmodule MockWorker do
    def perform(auction_id) do
      ["performed", auction_id]
    end
  end

  defmodule MockScheduler do
    def enqueue_at(_Exq, _default, time, worker, [auction_id]) do
      worker.perform(auction_id)
    end
  end

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

  describe "notify" do
    test "schedules the notification for the correct time and auction" do
      {:ok, user} = Accounts.create_user(@user_attrs)
      {:ok, auction} = Auctions.create_auction(Map.put(@auction_attrs, "user_id", user.id), MockDateTimePast)

      assert ["performed", auction.id] == Scheduler.notify(auction, MockWorker, MockScheduler)
    end
  end
end
