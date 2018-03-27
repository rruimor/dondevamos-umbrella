defmodule KiwiApiTest do
  use ExUnit.Case
  doctest KiwiApi

  test "greets the world" do
    assert KiwiApi.hello() == :world
  end
end
