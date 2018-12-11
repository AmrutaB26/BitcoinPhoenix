defmodule BitcoinWeb.PageController do
  use BitcoinWeb, :controller

  def index(conn, _params) do
    :ets.new(:table, [:bag, :named_table,:public])

    SSUPERVISOR.start_link(20)
    Enum.each(1..3, fn x-> MINERSERVER.start_link end)
    nbits = BLOCKCHAIN.calculateNBits()
    firstBlock = BLOCKCHAIN.createGenesisBlock(nbits)
    :ets.insert(:table,{"Blocks",1,firstBlock})
    transferAmt = Enum.random(1..24)
    TRANSACTION.transactionChain(2,transferAmt)
    Process.sleep(200)
    TASKFINDER.run(20, nbits, 0)
    render(conn, "index.html")
  end
end
