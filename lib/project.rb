module ProjectsHelper
  def projects
    @items.select { |item| item[:kind] == 'project' }
  end

  def sorted_projects
    projects.sort_by { |p| attribute_to_time(p[:created_at]) }.reverse
  end

  def project_image_url(item, type)
    '/images/portfolio/' + item[:image_id] + '_' + type + '.jpg'
  end
end

module AllHelper
  def all
    @items.select { |item| item[:kind] == 'project' || item[:kind] == 'article' }
  end

  def sorted_all
    all.sort_by { |p| attribute_to_time(p[:created_at]) }.reverse
  end
end


include ProjectsHelper
include AllHelper