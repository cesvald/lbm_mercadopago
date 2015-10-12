require_dependency "lbm_mercadopago/application_controller"

module LbmMercadopago
  class MercadopagoController < ApplicationController
  	skip_before_filter :verify_authenticity_token, :only => [:notifications]
	skip_before_filter :detect_locale, :only => [:notifications]
	skip_before_filter :set_locale, :only => [:notifications]
	skip_before_filter :force_http

    SCOPE = "projects.backers.checkout"

  	require 'mercadopago.rb'

  	def review
  		if !current_user
	      sign_in User.find_by_email("valderramago@gmail.com"), event: :authentication, store: true
	    end
      backer = current_user.backs.not_confirmed.find params[:id]
      if backer
        backer.update_attribute :payment_method, 'MercadoPago'
        
        #$mp = MercadoPago.new('1568386747490384', '5Z2hY446SdjpFPYGd8MSjj5UgkgdiNZc')
        $mp = MercadoPago.new('7422021614487510', 'BCTEIO9Qrsi40b26ruvIlmkYKPt2UEyG')
        
    		preference_data = {
          items: [
              {
              	#title: 'probando',
                title: t('payulatam_description', scope: SCOPE, :project_name => backer.project.name, :value => backer.display_value),
                quantity: 1,
                #unit_price: 25000,
                unit_price: backer.value.to_i,
                #currency_id: 'COP'
                currency_id: t('number.currency.format.unit')
              }
          ],
          payer: {
          	#email: 'valderramago@gmail.com',
          	#nombre: 'Cesar Valderrama'
            email: current_user.email,
            nombre: current_user.name
          },
          back_urls: {
            success: respond_mercadopago_url(backer),
            pending: respond_mercadopago_url(backer),
            failure: respond_mercadopago_url(backer)
          },
          additional_info: backer.id,
          notification_url: notification_mercadopago_index_url
        }
        @preference = $mp.create_preference(preference_data)
        puts @preference
      end
  	end

    def respond
    	backer = current_user.backs.find params[:id]
    	case params[:collection_status]
    	when 'pending'
    		flash[:failure] = t('mercadopago_pending', scope: SCOPE)
    	when 'approved'
    		flash[:failure] = t('mercadopago_approved', scope: SCOPE)
    	when 'in_process'
    		flash[:failure] = t('mercadopago_in_process', scope: SCOPE)
    	when 'in_mediation'
    		flash[:failure] = t('mercadopago_mediation', scope: SCOPE)
    	when 'rejected'
    		flash[:failure] = t('mercadopago_rejected', scope: SCOPE)
    	when 'cancelled'
    		flash[:failure] = t('mercadopago_cancelled', scope: SCOPE)
    	when 'refunded'
    		flash[:failure] = t('mercadopago_refunded', scope: SCOPE)
    	when 'charged_back'
    		flash[:failure] = t('mercadopago_charged_back', scope: SCOPE)
    	end
    	if params[:collection_status] == 'approved'
    		redirect_to main_app.project_backer_path(project_id: backer.project.id, id: backer.id)
    	else
    		redirect_to main_app.new_project_backer_path(backer.project)
    	end
    end

    def notification
      if params[:topic] && params[:id]

        $mp = MercadoPago.new('7422021614487510', 'BCTEIO9Qrsi40b26ruvIlmkYKPt2UEyG')
        merchant_order_info = nil

        if params[:topic] == 'payment'
          payment_info = $mp.get_payment(params[:id])
          puts payment_info
          merchant_order_info = $mp.get("/merchant_orders/" + payment_info["response"]["collection"]["merchant_order_id"].to_s)
          puts merchant_order_info
          backer = Backer.find(merchant_order_info["response"]["additional_info"])
          if backer
            case payment_info["status"]
            when 'approved'
              backer.confirm!
            when 'cancelled'
              backer.pendent!
            else
              backer.waiting!
            end

          end
        end
        render status: 200, nothing: true
      else
        render status: 404, nothing: true
      end
    end

    def create_user
      $mp = MercadoPago.new('1568386747490384', '5Z2hY446SdjpFPYGd8MSjj5UgkgdiNZc')
      response = $mp.post("/users/test_user", {site_id:"MCO"}, nil)
      respond_to do |format|
        format.html { }
        format.json {
            render json: {success:false, message: response} 
        }
      end
    end
  end
end