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

Define filter in controller
```ruby
# app/controllers/products_controller.rb

class ProductsController < ApplicationController

	search_filter :index, {url: :products_path} do
	  default_order "price", 'asc'
	
	  field :title, :string, :text, {label: 'Title', default_value: '', condition: :like_full}
	
	end

...
	

end

```
This will define filter with one field 'title' with value of type 'string' and form input of type 'text'.

Here, `:index` is the corresponding action name for which filter is defined.

Define `index` action in controller and use filter to get data:
```ruby
# app/controllers/products_controller.rb

class ProductsController < ApplicationController

...
def index
	@items = Product.by_filter (@filter)
end


end
```



### Search using GET request

By default, params for filter are passed using GET request.


```ruby
# app/controllers/products_controller.rb

class ProductsController < ApplicationController

	search_filter :index, {url: :products_path} do
	  ...
	
	end
...

end

```



### Search using POST request

If you want search form to be submitted by POST method use option ':search_method=>:post_and_redirect':

```ruby

class ProductsController < ApplicationController


search_filter :index, {save_session: true, search_method: :post_and_redirect, url: :products_url, search_url: :search_products_url, search_action: :search} do
  ...

end

def index
	@items = Product.by_filter (@filter)
end

end

```

If it is posted to a separate action (search_method: :post_and_redirect) then a route for search action should be created:

Define route for processiong POST request:
```ruby
# config/routes.rb
Myrails::Application.routes.draw do
	resources :products do
	  collection do
	    post 'search'
	end
end
```


Read more in [https://github.com/maxivak/simple_search_filter/wiki/search-post](Wiki-Search using POST)



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

### render search form

render form using simple_form with bootstrap:
```ruby
# render inline form
= inline_filter_form_for(@filter) 

# redner horizontal form
= horizontal_filter_form_for(@filter)
```


### sorting by columns:

Click on table header will sort data by the corresponding column. Another click on the same column will sort in reverse order.


```ruby
# app/views/products/index.html.haml

%h1 Products

Filter:
= inline_filter_form_for @filter
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


# Input Types

- text

- hidden


- select

```ruby
field :int, :string, :select, { label: 'Category', default_value: 0, collection: [['USD',1],['CAD',2]], label_method: :first, value_method: :last}

field :category_id, :int, :select, {label: 'Category', default_value: 0, collection: Category.all, label_method: :name, value_method: :id}
```

Options for select are taken from simple_form.

- autocomplete

```ruby
field :category, :string, :autocomplete, {label: 'Category', default_value: '', :source_query => :autocomplete_categories_url}
```

It uses [bootstrap3_autcomplete_input gem](https://github.com/maxivak/bootstrap3_autocomplete_input). See availableoptions in the [gem](https://github.com/maxivak/bootstrap3_autocomplete_input).

by default, it will be filtered by text field :category, not by id.

usually, field of type autocomplete is used to filter by id. Use option :search_by =>:id to search by id value:
```ruby
field :category, :string, :autocomplete, {search_by: :id, label: 'Category', default_value: '', :source_query => :autocomplete_categories_url}
```




# Features



# Examples

Find examples in [Wiki](https://github.com/maxivak/simple_search_filter/wiki/examples)


