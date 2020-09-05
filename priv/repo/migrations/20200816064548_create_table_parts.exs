defmodule BuildPc.Repo.Migrations.CreateTableParts do
  use Ecto.Migration

  def up do
    create table(:parts, primary_key: false) do
      add :code, :string, primary_key: true
      add :name, :string
      add :description, :text
      add :profile_image, :text
      add :type, :string
      add :part_type, :string
      add :price, :string
      add :brand_code, :string
      add :version, :string
      add :inserted_by, :string
      add :updated_by, :string
      timestamps()
    end
  end

  def down do
    drop table(:parts)
  end
end
