class Annotation < ActiveRecord::Base
  belongs_to :annotateable, :polymorphic => true, :counter_cache => 'articles_count'
  belongs_to :article

  validates_uniqueness_of :article_id, :scope => [:annotateable_id, :annotateable_type]
  after_create :update_caches

  private
  def update_caches
    annotateable.update_articles!
    article.update_caches!
  end
end