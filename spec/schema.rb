ActiveRecord::Schema.define(:version => 0) do
  create_table :users do |t|
    t.string :name
  end
  
  create_table :comments do |t|
    t.string :gloo_model_id
    t.text :body
  end
end

