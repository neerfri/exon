defmodule Exon.TestApp.Domain.Commands do
  defmodule CreateTodoList do
    use Exon.Command
    fields do
      field :list_id
    end
  end

  defmodule CreateTodoItem do
    use Exon.Command
    fields do
      field :list_id
      field :item_id
      field :title
    end
  end

  defmodule MarkTodoItemComplete do
    use Exon.Command
    fields do
      field :list_id
      field :item_id
    end
  end

  defmodule MarkTodoItemNotComplete do
    use Exon.Command
    fields do
      field :list_id
      field :item_id
    end
  end
end
