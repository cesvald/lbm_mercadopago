LbmMercadopago::Engine.routes.draw do
	root :to => 'mercadopago#review'
	resources :mercadopago do
	  collection do
	    get :notification
	    get :create_user
	    get :pay
	  end
	  member do
	  	get :respond
	  	get :review
	  end
	end
end
