defmodule Athasha.Edge do

  import Ecto.Query, warn: false
  alias Athasha.Repo

  alias Athasha.Edge.Node
  
  def nodes_by_user(user_id) do
    Node
      |> where([n], n.user_id == ^user_id)
      |> preload([:ports])
      |> Repo.all()    
  end

  def create_node!(%Node{} = node) do
    node 
    |> Node.changeset(%{})
    |> Repo.insert!()
  end

end
