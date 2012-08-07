require 'test_helper'

class AddingPostsTest < ActionDispatch::IntegrationTest
  fixtures :all

  test "adding posts and commenting" do
    get "/"
    assert_response :success
    assert_select "body > a", "Posts"

    get "/posts"
    assert_response :success

    get "/posts/new"
    assert_response :success

    assert_difference("Post.count", 1) do
      post "/posts", post: {title: "Hello World", body: "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", published: true}
    end
    assert_equal "Post was successfully created.", flash[:notice]

    @post = assigns(:post)
    assert_redirected_to @post

    assert_difference("@post.comments.count", 1) do
      post "/comments", comment: {post_id: @post.id, body: "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." }
    end
    assert_redirected_to @post
  end

end
