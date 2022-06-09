defmodule TodoListWeb.Api.Schema do
  use Absinthe.Schema

  object :todo_item do
    field :id, non_null(:id) # corresponds to ID in graphql
    field :content, non_null(:string)

    field :is_completed, non_null(:boolean) do
      resolve(fn %{completed_at: completed_at}, _, _ ->
        {:ok, !is_nil(completed_at)}
      end)
    end
  end

  mutation do
    field :create_todo_item, non_null(:boolean) do
      arg :content, non_null(:string)

      resolve(fn %{content: content}, _ ->
        case TodoList.Todos.create_item(%{content: content}) do
          {:ok, %TodoList.Todos.Item{}} ->
            {:ok, true}
        _ ->
          {:ok, false}
        end
      end)
    end

    field :toggle_todo_item, :todo_item do
      arg(:id, non_null(:id))

      resolve(fn %{id: item_id}, _ ->
        TodoList.Todos.toggle_item_by_id(item_id)
      end)
    end
  end

  query do
    field :hello, :string do
      resolve(fn _, _ ->
        {:ok, "Hello world!"}
      end)
    end

    field :todo_items, non_null(list_of(:todo_item)) do # [TodoItem!]! in graphql
      resolve(fn _, _ ->
        {:ok, TodoList.Todos.list_items()}
      end)
    end
  end
end
