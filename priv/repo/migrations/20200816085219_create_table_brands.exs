defmodule BuildPc.Repo.Migrations.CreateTableBrands do
  use Ecto.Migration

  def up do
    create table(:brands, primary_key: false) do
      add :code, :string, primary_key: true
      add :name, :string
      add :description, :text
      add :profile_image, :text
      add :version, :string
      add :inserted_by, :string
      add :updated_by, :string
      timestamps()
    end
  end

  def down do
    drop table(:brands)
  end
end
