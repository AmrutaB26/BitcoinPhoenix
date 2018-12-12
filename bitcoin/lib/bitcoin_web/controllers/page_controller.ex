defmodule BitcoinWeb.PageController do
  use BitcoinWeb, :controller
  alias Bitcoin.Repo
  alias Bitcoin.Blocks

  def index(conn, _params) do
    :ets.new(:table, [:bag, :named_table,:public])

    SSUPERVISOR.start_link(20)
    Enum.each(1..3, fn x-> MINERSERVER.start_link end)
    nbits = BLOCKCHAIN.calculateNBits()
    firstBlock = BLOCKCHAIN.createGenesisBlock(nbits)
    :ets.insert(:table,{"Blocks",1,firstBlock})
    transferAmt = Enum.random(1..24)
    TRANSACTION.transactionChain(20,transferAmt)
    Process.sleep(200)
    TASKFINDER.run(2, nbits, 0)
    data = fetchRecords()
    #IO.inspect :ets.lookup(:table, "Blocks")
    IO.inspect data
    #Jason.encode!(%{"age" => 44, "name" => "Steve Irwin", "nationality" => "Australian"})
    render(conn,"index.html", chart: data)
  end

  def fetchRecords do
    list = Repo.all(Blocks)
    |> Enum.map(fn x->
      {_,out} = Map.fetch(x, :transCount)
      Decimal.to_integer out
    end)
    list
  end
end
