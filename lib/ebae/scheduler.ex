defmodule Ebae.Scheduler do
  alias Ebae.EmailWorker

  def notify(auction, worker \\ EmailWorker, scheduler \\ Exq) do
    scheduler.enqueue_at(scheduler, "default", auction.finish, worker, [auction.id])
  end
end
