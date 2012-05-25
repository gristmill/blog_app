# Starting a New Application

Assuming you already have rails installed, you can create a new application with the "rails new" command. This command will create the
directory structure and install dependencies.

```bash
rails new blog_app
```

# Starting the Web Server

Navigate into the directory that was just created and start the development server.

```bash
cd blog_app
rails server
```

If you visit [http://localhost:3000](http://localhost:3000), you should see a welcome screen.
This comes with every new Rails app. The first thing you have to do is delete it!

```bash
rm public/index.html
```

Now when you refresh the page you will be greeted with a nice error :)

```bash
No route matches [GET] "/"
```

Let's remedy the situation.

We will create a controller that we will declare as the root of our application.

```bash
rails generate controller home index
```
After the command finishes we need to tell Rails to use the Home controller and the index action as our root. We declare all application
routes in the config/routes.rb directory. We need to add the following to the file:

```ruby
BlogApp::Application.routes.draw do
  root :to => 'home#index'
end
```
If you go back to the browser you should see the error is resolved.

# Creating a Resource

Rails comes with something called "scaffolding". It allows you to bootstrap a resource with standard database backed CRUD actions.
When you run the scaffold command routes will be added to the config/routes.rb file and a controller, model and migration will be created.
Everything needed for CRUD will work automatically.

Let's give it a whirl!

```bash
rails generate scaffold Post title:string body:text published:boolean
```

After a migration is added to your project (scaffolding adds one for you) you have to "migrate" your database. Migrations apply changes to your
database, adding, changing or removing columns, tables and indexes.

Working with the database is really abstracted in Rails, so that most of the time you're working with Ruby rather than SQL!

You migrate the databse with the following command:

```bash
rake db:migrate
```
## The Application Layout

Views are kept in app/views. The applications layout is kept in app/views/layouts. We are going to open up this file and add a link so that we
can navigate in the browser to the resource we just created.

You can add this code anywhere in the file app/views/layouts/application.html.erb

```erb
<%= link_to "Posts", posts_path %>
```
so that it looks like this

```erb
<!DOCTYPE html>
<html>
<head>
  <title>BlogApp</title>
  <%= stylesheet_link_tag    "application", :media => "all" %>
  <%= javascript_include_tag "application" %>
  <%= csrf_meta_tags %>
</head>
<body>

<%= link_to "Posts", posts_path %>
<%= yield %>

</body>
</html>
```

Reload the browser and click on the link and a few posts!

## Adding Comments
The internet would be boring without trolling, so let's add support for it in our application. Now we aren't going to use scaffolding for comments. We could,
but in this case it might be overkill. We will use a couple other rails commands to achieve the same thing but a little leaner.

To create just a model and a migration, we use this command

```bash
rails generate model comment post_id:integer body:text
```

And because a migration was added we will also need to migrate our database again.

```bash
rake db:migrate
```
## Basic Associtations

We are going to wire up our two models with the has_many and a belongs_to associations.

The "post_id" we entered on the command line is the attribute that will be used as the foreign key to our Post relationship.

```ruby
# app/models/post.rb
class Post < ActiveRecord::Base
  attr_accessible :body, :published, :title
  has_many :comments
end

```

```ruby
# app/models/comment.rb
class Comment < ActiveRecord::Base
  attr_accessible :body, :post_id
  belongs_to :post
end
```
Now let's dive into the console!

## The Console

You can play around with your entire app from a console session. Our Post and Comment models are available to us, so let's see if our associations are working.

To enter into a console session, just type from the root of your application directory

```bash
rails console
```

Once it boots up you can play around

```ruby
Post.all
Post.first
Post.first.comments

comment = Post.last.comments.new

comment.post
```

Working inside of the console is a great way to become familiar with the Rails environment. It is an incredibly useful and powerful tool.


# Finishing up Comments

We have created a Commnet model and a migrations and our associations work as expected. We now need to support them in the interface.

Exit the console and enter this from the command line.

```bash
rails generate controller comments
```

We are only going to add one action to this controller. But We first have to edit our routes file.
Add the following line to config/routes.rb

```ruby
  resources :comments, :only => :create
```
so that it looks like this

```ruby
BlogApp::Application.routes.draw do
  resources :posts

  resources :comments, :only => :create

  root :to => 'home#index'
end
```

The generated controller is empty by default. We're only adding one method, the create method.

Edit app/controllers/comments_controller.rb so that it looks like this

```ruby
class CommentsController < ApplicationController
  def create
    @comment = Comment.new(params[:comment])
    @comment.save

    redirect_to @comment.post
  end
end
```

The create method will instantiate a new comment, save it and redirect the user to the comment's associated post.

Because we're showing comments on the PostsController show page, we will have to also instantiate them.

Find the show action in app/controllers/posts_controller.rb and add these two lines

```ruby
@comments = @post.comments.all
@comment = @post.comments.new
```

So that it looks like

```ruby
# GET /posts/1
# GET /posts/1.json
def show
  @post = Post.find(params[:id])
  @comments = @post.comments.all
  @comment = @post.comments.new

  respond_to do |format|
    format.html # show.html.erb
    format.json { render json: @post }
  end
end

```

## Showing Comments in the Views

We next need to add a couple of partials to the app/views/comments directory that was just created.

Add the following two files to app/views/comments directory. And note that each of these files starts with an underscore "_".

```ruby
touch app/views/comments/_comment.html.erb
touch app/views/comments/_form.html.erb
```
These are known as "partials". Partials are designated by an underscore in the filename. Partials are included by other views and help keep your
view files small and clean.

Add these two lines to app/views/posts/show.html.erb

```erb
<%= render "comments/form" %>
<%= render @comments %>
```

So that the file looks like


```erb
<p id="notice"><%= notice %></p>

<p>
  <b>Title:</b>
  <%= @post.title %>
</p>

<p>
  <b>Body:</b>
  <%= @post.body %>
</p>

<p>
  <b>Published:</b>
  <%= @post.published %>
</p>

<%= render "comments/form" %>
<%= render @comments %>

<%= link_to 'Edit', edit_post_path(@post) %> |
<%= link_to 'Back', posts_path %>
```


In the form partial (app/views/comments/_form.html.erb) add this code

```erb
<%= form_for @comment do |f| %>
  <%= f.hidden_field :post_id %>
  <%= f.text_area :body %>
  <%= f.submit "Submit", :disable_with => 'Submitting' %>
<% end %>
```

And in the _comment.html.erb file add this code

```erb
<%= div_for comment do %>
  <strong><%= comment.body %></strong>
  <%= distance_of_time_in_words_to_now comment.created_at %>
<% end %>
```

## That's it!

You now have a working Ruby on Rails application!

## Resources

Ruby on Rails has a vibrant community. The following people are pretty influential in the Rails community.

## Awesome Rails Core Developers

- David Heinemeier Hansson aka DHH http://twitter.com/dhh
- Yehuda Katz - http://yehudakatz.com/
- Jose Valim - http://plataformatec.com.br/

## Community Members Involved with Rails Education
- Greg Pollack - http://envylabs.com and http://codeschool.com
- Ryan Bates - http://railscasts.com
- Peter Cooper - http://peterc.org/

## Great Resources for Learning Rails
- http://rubyonrails.org
- http://guides.rubyonrails.org
- http://railscasts.com
- http://rubygems.org

## Educational Ruby and Rails Newsletter
- http://rubyweekly.com
