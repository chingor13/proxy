defmodule Proxy.Router do
  use Proxy.Web, :router

  scope "/", Proxy do
    get "/*path", ProxyController, :proxy
  end

end
