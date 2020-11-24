class AssetRenderer < RichTextRenderer::BaseNodeRenderer
  def render(node)
  	"<img src='https:#{node['data']['target']['url']}'/>"
  end
end