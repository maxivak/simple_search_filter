simple_search_filter
=============================

The gem makes it easier to create search filters for your pages.
It helps create forms for search filters, sort, paginate data.
Search filters are forms used to filters the rows on pages with list/table data.

The gem uses kaminari for pagination, simple_form with bootstrap styles for building forms.

# Installation

Gemfile:
```ruby
gem 'simple_search_filter'
```

bundle install


# Usage

## Controller

```ruby
class ProductsController < ApplicationController

search_filter :index, {url: :products_path} do

  default_order "price", 'asc'

  field :title, :string, :text, {label: 'Title', default_value: '', condition: :like_full}


end

def index
	@items = Product.by_filter (@filter)

	# or
	@items = Product.where(@filter.where).order(@filter.order_string).page(@filter.page)

	# or use filter values in where
	category_id = @filter.v(:category_id)

	@items = Product.where(:category_id=> category_id).page(@filter.page)

end


end
```

This will define filter with one field 'title' with value of type 'string' and form input of type 'text'.


## Model

Include into your model to define scope:

```ruby
class Product < ActiveRecord::Base
   # ...

  searchable_by_simple_filter
end
```

it defines scope `:search_by_filter`, which can be used as `Product.search_by_filter(@filter)`


## View

view helpers:

render form using simple_form with bootstrap:
```ruby
= inline_filter_form_for(@filter)
= horizontal_filter_form_for(@filter)
```


sorting by columns:

Click on table header will sort data by the corresponding column. Another click on the same column will sort in reverse order.


```ruby
# app/views/products/index.html.haml

%h1 Products

Filter:
= filter_form_for @filter
-#= inline_filter_form_for @filter
-#= horizontal_filter_form_for @filter
%br
%table.table
  %tr
    %th= link_to_sortable_column :title, 'Title'
    %th= link_to_sortable_column :price, 'Price'

  - @items.each do |item|
    %tr
      %td=item.title
      %td= item.price
```





# Examples

Find examples in [Wiki](https://github.com/maxivak/simple_search_filter/wiki/examples)


