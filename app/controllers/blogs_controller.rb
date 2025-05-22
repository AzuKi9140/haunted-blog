# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_owned_blog, only: %i[edit update destroy]
  before_action :ensure_viewable_blog, only: %i[show]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show; end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_owned_blog
    @blog = current_user.blogs.find(params[:id])
  end

  def ensure_viewable_blog
    blog_id = params[:id]

    @blog = if user_signed_in?
              Blog.published.or(current_user.blogs).find(blog_id)
            else
              Blog.published.find(blog_id)
            end
  end

  def blog_params
    permitted_params = %i[title content secret]

    permitted_params << :random_eyecatch if current_user.premium?

    params.require(:blog).permit(*permitted_params)
  end
end
