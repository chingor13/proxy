defmodule Proxy.Router do
  use Proxy.Web, :router

  scope "/", Proxy do
    get "/*path", ProxyController, :get
    post "/*path", ProxyController, :post
  end

end
