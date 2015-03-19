class WordToNewMethod < ActiveRecord::Migration
  def change
    remove_column :words, :properties, :string, array: true
    remove_column :words, :variant, :string, array: true
    remove_column :words, :root_id, :integer
    remove_column :words, :pronunciation, :string

    rename_column :words, :word, :lexical_form

    # noun, article

    add_column :words, :singular_nominative, :string
    add_column :words, :singular_vocative, :string
    add_column :words, :singular_accusative, :string
    add_column :words, :singular_genitive, :string
    add_column :words, :singular_dative, :string
    add_column :words, :plural_nominative, :string
    add_column :words, :plural_accusative, :string
    add_column :words, :plural_genitive, :string
    add_column :words, :plural_dative, :string

    # adjective

    add_column :words, :feminine_singular_nominative, :string
    add_column :words, :feminine_singular_vocative, :string
    add_column :words, :feminine_singular_accusative, :string
    add_column :words, :feminine_singular_genitive, :string
    add_column :words, :feminine_singular_dative, :string
    add_column :words, :feminine_plural_nominative, :string
    add_column :words, :feminine_plural_accusative, :string
    add_column :words, :feminine_plural_genitive, :string
    add_column :words, :feminine_plural_dative, :string

    add_column :words, :masculine_singular_nominative, :string
    add_column :words, :masculine_singular_vocative, :string
    add_column :words, :masculine_singular_accusative, :string
    add_column :words, :masculine_singular_genitive, :string
    add_column :words, :masculine_singular_dative, :string
    add_column :words, :masculine_plural_nominative, :string
    add_column :words, :masculine_plural_accusative, :string
    add_column :words, :masculine_plural_genitive, :string
    add_column :words, :masculine_plural_dative, :string

  end
end
