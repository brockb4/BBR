# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 0) do

  create_table "awards", :id => false, :force => true do |t|
    t.string  "facility",       :limit => 75
    t.decimal "wh",                           :precision => 3,  :scale => 0
    t.decimal "item_num",                     :precision => 12, :scale => 0
    t.string  "item_name",      :limit => 75
    t.decimal "qty_given",                    :precision => 15, :scale => 0
    t.string  "vendor",         :limit => 50
    t.decimal "min_ord_qty",                  :precision => 6,  :scale => 0
    t.decimal "weight",                       :precision => 6,  :scale => 3
    t.decimal "pallet_qty",                   :precision => 8,  :scale => 0
    t.string  "purchase_group", :limit => 50
  end

  create_table "rebate_purchases", :id => false, :force => true do |t|
    t.string  "vendor",         :limit => 50
    t.decimal "item_num",                     :precision => 8,  :scale => 0
    t.decimal "releasedqty",                  :precision => 12, :scale => 0
    t.decimal "relqtyreceived",               :precision => 12, :scale => 0
    t.decimal "masterpoqty",                  :precision => 12, :scale => 0
  end

  create_table "rebates", :id => false, :force => true do |t|
    t.string  "vendor", :limit => 50
    t.decimal "target",               :precision => 8,  :scale => 4
    t.decimal "volume",               :precision => 10, :scale => 0
    t.decimal "rebate",               :precision => 8,  :scale => 4
  end

  create_table "vendors", :id => false, :force => true do |t|
    t.string  "vendor_name", :limit => 50
    t.decimal "lead_time",                 :precision => 3, :scale => 1
    t.decimal "pallet_max",                :precision => 3, :scale => 1
    t.decimal "pallet_min",                :precision => 3, :scale => 0
    t.decimal "weight_min",                :precision => 7, :scale => 2
    t.decimal "weight_max",                :precision => 7, :scale => 2
  end

end
