defmodule Todos.Error do
  def extract(changeset) do
    errors =
      Enum.map(changeset.errors, fn {field, detail} ->
        %{
          field: field,
          detail: get_detail(detail)
        }
      end)

    %{errors: errors}
  end

  def get_detail({message, values}) do
    Enum.reduce(values, message, fn {k, v}, acc ->
      String.replace(acc, "%{#{k}}", to_string(v))
    end)
  end

  def get_detail(message), do: message
end
