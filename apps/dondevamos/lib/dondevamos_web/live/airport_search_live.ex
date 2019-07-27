defmodule DondevamosWeb.AirportSearchLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <form phx-change="suggest" phx-submit="search">
      <label>Origin
      <input type="text"
             name="origin"
             value="<%= @origin %>"
             list="matches"
             placeholder="Origin..."
             phx-blur="set_origin"
             <%= if @loading, do: "readonly" %>
      />
      <datalist id="matches">
        <%= for match <- @matches do %>
          <option value="<%= "#{match["id"]}" %>"><%= "#{match["name"]} #{match["id"]}" %></option>
        <% end %>
      </datalist>
      </label>
      <label>Departure
        <input type="date"
               id="outbound_date"
               name="outbound_date"
               value="<%= @outbound_date %>">
      </label>
      <button>Search</button>
    </form>
    <div class="searchResults">
      <%= for result <- @results do %>
        <div class="result">
          <div class="itinerary">
            <%= result["city_from"] %> &rarr; <%= result["city_to"] %> <%= result["price"] %> EUR
          </div>
          <div class="times">

          </div>
        </div>
      <% end %>
    </div>
    """
  end

  def mount(_session, socket) do
    {:ok, assign(socket, origin: nil, outbound_date: nil, results: [], loading: false, matches: [])}
  end

  def handle_event("suggest", %{"origin" => origin}, socket) when byte_size(origin) <= 100 do
    locations =
      KiwiApi.Airports.by_location(origin)
      |> Map.get("locations")
      |> Enum.map(fn location -> location |> Map.take(["id", "name", "city"]) end)

    {:noreply, assign(socket, matches: locations)}
  end

  def handle_event("set_origin", value, socket) do
    {:noreply, assign(socket, origin: value)}
  end

  def handle_event("search", form, socket) do
    send(self(), {:search, form})
    {:noreply, assign(socket, origin: form["origin"], outbound_date: form["outbound_date"], loading: true, matches: [], results: [])}
  end

  def handle_info({:search, form}, socket) do
    [year, month, day] = form["outbound_date"] |> String.split("-")

    date_from = "#{day}/#{month}/#{year}"
    flight_query = %{
      fly_from: form["origin"],
      fly_to: "",
      date_from: date_from,
      date_to: date_from
    }

    results =
      KiwiApi.Flights.search(flight_query, %{direct_flights: 1})
      |> IO.inspect()

    {:noreply, assign(socket, loading: false, results: results, matches: [])}
  end
end
