require 'test_helper'

class Site::ArticlesControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    @article = create :article, :user => @user, :status => 'publish'
    @request.host = "#{@user.name}.#{APP_CONFIG["host"]}"
  end

  test "should get index" do
    get :index
    assert_equal @user, assigns(:user)
    assert_response :success, @response.body
  end

  test "should get index when setting domain" do
    @user.update_attribute :domain, 'custom.domain'

    get :index
    assert_redirected_to "http://#{@user.domain}/"

    @request.host = 'custom.domain'
    get :index
    assert_equal @user, assigns(:user)
    assert_response :success, @response.body
  end

  test "should get show" do
    get :show, :id => @article
    assert_response :success, @response.body
  end

  test "should redirect when urlname wrong" do
    article = create(:article, :user => @user, :urlname => 'test2', :status => 'publish')
    get :show, :id => article
    assert_redirected_to site_article_url(article, :urlname => article.urlname)
  end


  test "should get feed" do
    get :feed, :format => :rss
    assert_response :success, @response.body
  end
end
