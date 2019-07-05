source 'https://supermarket.chef.io'

Dir.glob('./cookbooks/*') do |item|
  cookbook item.split('/').last, path: item
end
