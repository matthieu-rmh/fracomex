defmodule Fracomex.Products do
  @moduledoc """
  The Products context.
  """

  import Ecto.Query, warn: false
  alias Fracomex.Repo

  alias Fracomex.Products.{Item, ItemFamily, ItemSubFamily}
  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items do
    Repo.all(Item)
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> get_item!(123)
      %Item{}

      iex> get_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item!(id), do: Repo.get!(Item, id)

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{field: value})
      {:ok, %Item{}}

      iex> create_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a item.

  ## Examples

      iex> delete_item(item)
      {:ok, %Item{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> change_item(item)
      %Ecto.Changeset{data: %Item{}}

  """
  def change_item(%Item{} = item, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end



  @doc """
  Returns the list of item_families.

  ## Examples

      iex> list_item_families()
      [%ItemFamily{}, ...]

  """
  def list_item_families do
    Repo.all(ItemFamily)
  end

  def list_item_family_ids do
    query = from item_family in ItemFamily,
            select: item_family.item_family_id
    Repo.all(query)
  end

  @doc """
  Gets a single item_family.

  Raises `Ecto.NoResultsError` if the Item family does not exist.

  ## Examples

      iex> get_item_family!(123)
      %ItemFamily{}

      iex> get_item_family!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item_family!(id), do: Repo.get!(ItemFamily, id)

  def get_item_family_caption!(id) do
    query = from item_family in ItemFamily,
            where: item_family.item_family_id == ^id,
            select: item_family.caption
    Repo.one(query)
  end
  @doc """
  Creates a item_family.

  ## Examples

      iex> create_item_family(%{field: value})
      {:ok, %ItemFamily{}}

      iex> create_item_family(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item_family(attrs \\ %{}) do
    %ItemFamily{}
    |> ItemFamily.changeset(attrs)
    |> Repo.insert()
  end

  def insert_item_families(list) do
    Repo.insert_all(ItemFamily, list)
  end

  @doc """
  Updates a item_family.

  ## Examples

      iex> update_item_family(item_family, %{field: new_value})
      {:ok, %ItemFamily{}}

      iex> update_item_family(item_family, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item_family(%ItemFamily{} = item_family, attrs) do
    item_family
    |> ItemFamily.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a item_family.

  ## Examples

      iex> delete_item_family(item_family)
      {:ok, %ItemFamily{}}

      iex> delete_item_family(item_family)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item_family(%ItemFamily{} = item_family) do
    Repo.delete(item_family)
  end

  def delete_item_families(ids) do
    query = from item_family in ItemFamily,
            where: item_family.item_family_id in ^ids
    Repo.delete_all(query)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item_family changes.

  ## Examples

      iex> change_item_family(item_family)
      %Ecto.Changeset{data: %ItemFamily{}}

  """
  def change_item_family(%ItemFamily{} = item_family, attrs \\ %{}) do
    ItemFamily.changeset(item_family, attrs)
  end



  @doc """
  Returns the list of item_sub_families.

  ## Examples

      iex> list_item_sub_families()
      [%ItemSubFamily{}, ...]

  """
  def list_item_sub_families do
    Repo.all(ItemSubFamily)
  end

  @doc """
  Gets a single item_sub_family.

  Raises `Ecto.NoResultsError` if the Item sub family does not exist.

  ## Examples

      iex> get_item_sub_family!(123)
      %ItemSubFamily{}

      iex> get_item_sub_family!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item_sub_family!(id), do: Repo.get!(ItemSubFamily, id)

  @doc """
  Creates a item_sub_family.

  ## Examples

      iex> create_item_sub_family(%{field: value})
      {:ok, %ItemSubFamily{}}

      iex> create_item_sub_family(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item_sub_family(attrs \\ %{}) do
    %ItemSubFamily{}
    |> ItemSubFamily.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a item_sub_family.

  ## Examples

      iex> update_item_sub_family(item_sub_family, %{field: new_value})
      {:ok, %ItemSubFamily{}}

      iex> update_item_sub_family(item_sub_family, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item_sub_family(%ItemSubFamily{} = item_sub_family, attrs) do
    item_sub_family
    |> ItemSubFamily.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a item_sub_family.

  ## Examples

      iex> delete_item_sub_family(item_sub_family)
      {:ok, %ItemSubFamily{}}

      iex> delete_item_sub_family(item_sub_family)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item_sub_family(%ItemSubFamily{} = item_sub_family) do
    Repo.delete(item_sub_family)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item_sub_family changes.

  ## Examples

      iex> change_item_sub_family(item_sub_family)
      %Ecto.Changeset{data: %ItemSubFamily{}}

  """
  def change_item_sub_family(%ItemSubFamily{} = item_sub_family, attrs \\ %{}) do
    ItemSubFamily.changeset(item_sub_family, attrs)
  end
end
