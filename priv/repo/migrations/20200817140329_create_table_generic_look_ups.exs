defmodule BuildPc.Repo.Migrations.CreateTableGenericLookUps do
  use Ecto.Migration

  def up do
    create table(:generic_look_ups, primary_key: false) do
      add :code, :string, primary_key: true
      add :type, :string
      add :name, :string
      add :description, :string
    end
    create unique_index(:generic_look_ups, [:type, :code])
  end

  def down do
    drop table(:generic_look_ups)
  end
end
