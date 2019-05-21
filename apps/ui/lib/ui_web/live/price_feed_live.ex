defmodule UiWeb.PriceFeedLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div class="row">
    <div class="col-xs-12">
      <div class="box">
        <div class="box-header">
          <h3 class="box-title">Current prices</h3>

          <div class="box-tools">
            <div class="input-group input-group-sm" style="width: 180px;">
              <form phx_change="validate" phx-submit="validate">
                <input type="text" name="search" class="form-control pull-right" placeholder="Search">

                <div class="input-group-btn">
                  <button type="submit" class="btn btn-default"><i class="fa fa-search"></i></button>
                </div>
              </form>
            </div>
          </div>
        </div>
        <!-- /.box-header -->
        <%= if length(@ticks) > 0 do %>
          <div class="box-body table-responsive no-padding">
            <table class="table table-hover">
              <tbody><tr>
                <th>Symbol</th>
                <th>Price</th>
              </tr>
              <%= for tick <- Keyword.values(@ticks) do %>
              <tr>
                <td><%= tick.symbol %></td>
                <td><%= tick.price %></td>
              </tr>
              <% end %>
            </tbody></table>
          </div>
        <% else %>
          <div class="box-body">
            You are not streaming any symbols at the moment. Go to "Streaming settings" to enable
            streaming on symbols that will show up here
          </div>
        <% end %>
        <!-- /.box-body -->
      </div>
      <!-- /.box -->
    </div>
  </div>
"""
  end

  def mount(%{}, socket) do
    ticks = Hefty.fetch_streaming_symbols()
      |> symbols_to_keywords

      ticks
        |> Keyword.keys()
        |> Enum.map(&(UiWeb.Endpoint.subscribe("stream-#{&1}")))

    {:ok, assign(socket, ticks: ticks)}
  end

  def handle_event("validate", %{"search" => search}, socket) do
    ticks = Hefty.fetch_streaming_symbols(search)
      |> symbols_to_keywords

    # todo: possibly unsubrice all non-showing symbols here

    {:noreply, assign(socket, ticks: ticks)}
  end

  def handle_info(%{event: "trade_event", payload: event}, socket) do
    ticks = Keyword.update!(
      socket.assigns.ticks,
      :"#{event.symbol}",
      &(%{&1 | :price => event.price})
    )

    {:noreply, assign(socket, ticks: ticks)}
  end

  defp symbols_to_keywords(symbols) do
    symbols
    |> Enum.map(&(elem(&1, 0)))
    |> Enum.map(&(Hefty.fetch_tick(&1)))
    |> Enum.into([], &{:"#{&1.symbol}", &1})
  end
end

