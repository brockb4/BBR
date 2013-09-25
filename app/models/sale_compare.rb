class SaleCompare

  def initialize
    @results = PosSale.connection.select_all("select
      patch,assortment,
      item_num,
      description,
      shape,
      color,
      oc_item_num,
      units_2011,
      sales_2011,
      OC_units_2010,
      OC_sales_2010,
      sum(units_2011/nullif((oc_units_2010),0)) as units_pct_sold_vs_oc,
      sum(sales_2011/nullif((OC_sales_2010),0)) as sales_pct_sold_vs_oc
      from
      (
      select
      r1.patch,
      r1.assortment,
      r1.description,
      shape,
      color,
      r1.item_num,
      r1.oc_item_num,
      units_2011,
      sales_2011,
      units_2010 as OC_units_2010,
      sales_2010 as OC_sales_2010
      from
      (
      select patch,
      item_ref.assortment as assortment,
      item_ref.item_num,
      item_ref.description as description,
      shape,
      color,
      oc_item_num,
      sum(ty_sales_units) as units_2011,
      sum(ty_sales) as sales_2011
      from item_ref
      inner join pos_sales on (item_ref.item_num=pos_sales.item_num) and (item_ref.assortment=pos_sales.assortment)
      where week between '2011-01-01' and '2011-12-31'
      group by patch,item_ref.assortment,item_ref.item_num,item_ref.description,shape,color,oc_item_num
      ) as r1
      left join oc_sales on (r1.patch=oc_sales.patch) and (r1.assortment=oc_sales.assortment) and (r1.oc_item_num=oc_sales.oc_item_num)
      group by r1.patch,r1.assortment,r1.description,shape,color,r1.item_num,r1.oc_item_num,units_2011,sales_2011,units_2010,sales_2010
      ) as r2
      group by patch,assortment,item_num,description,shape,color,oc_item_num,units_2011,sales_2011,OC_units_2010,OC_sales_2010")
  end

  def results
    @output = []
    @output << generate_headers
    process_results(@results)
    @output.collect {|x| x.to_csv}.join('')
  end

  protected

  def generate_headers
    header =  ['Patch', 'Assortment', 'Item #', 'Description', 'Shape', 'Color']
    header += ['OC Item #', 'Units 2011', 'Sales 2011', 'OC Units 2010', 'OC Sales 2010']
    header += ['% of Units Sold vs OC 2010', '% of Sales vs OC 2010']
  end

  def process_results(results)
    results.each do |res|
      line = [res["patch"], res["assortment"], res["item_num"], res["description"], res["shape"], res["color"], res["oc_item_num"], res["units_2011"], res["sales_2011"], res["OC_units_2010"], res["OC_sales_2010"], res["units_pct_sold_vs_oc"], res["sales_pct_sold_vs_oc"]]

      @output << line
    end
  end
end
