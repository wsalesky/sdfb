Sdfb::Application.routes.draw do

  # API Routes
  defaults format: :json, via: [:get] do
    get  'api/all_people'
    get  'api/people'
    get  'api/users'
    get  'api/all_relationships'
    get  'api/relationships'
    get  'api/recent_contributions'
    get  'api/groups'
    get  'api/groupnames'
    get  'api/network'
    get  'api/groups/network', action: :group_network, controller: :api
    get  'api/typeahead'
    get  'api/curate/:type', action: :curate, controller: :api
    post 'api/edit_user'
    post 'api/new_user'
    post 'api/write'
    post 'api/sign_in', action: :create, controller: :sessions
    post 'api/sign_out', action: :destroy, controller: :sessions
    post 'api/request_password_reset', action: :create, controller: :password_resets
    post 'api/password_reset', action: :update, controller: :password_resets
  end
end
