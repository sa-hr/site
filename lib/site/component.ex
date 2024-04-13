defmodule Site.Component do
  use Phoenix.Component

  defmacro __using__(_) do
    quote do
      use Phoenix.Component
      import unquote(__MODULE__)
    end
  end

  def inner_content(%{content: content} = assigns) when is_binary(content) do
    ~H"""
    <%= Phoenix.HTML.raw(@content) %>
    """
  end

  def inner_content(assigns) do
    ~H"""
    <%= @content %>
    """
  end
end
