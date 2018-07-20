anaconda auth --create --name ANACONDA_GGD_TOKEN --org ggd-alpha --scopes 'repos api:write api:read'>token
gem install travis && travis login
travis encrypt ANACONDA_GGD_TOKEN=$(cat token) --add env.global
