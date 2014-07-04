class CertificatesController < ApplicationController
expose(:certificate,  attributes: :certificate_params)
expose(:ca){Certificate.all.where(root: true)}

def new
end

def create
  if certificate.save
    if certificate.root
      redirect_to certificate_path(certificate)
    else
      send_data download_cert, :filename => "#{certificate.id}.pem"
    end
  else
    render :new
  end
end

def show
end

private

def download_cert
      r = CertificateAuthority::Certificate.new
      r.subject.common_name=  certificate.parent
      r.serial_number.number=1
      r.key_material.generate_key
      r.signing_entity = true
      signing_profile =
      {
        "extensions" =>
          {
          "basicConstraints" => {"ca" => true},"keyUsage" => {"usage" => ["critical", "keyCertSign"] }
          }
      }
      r.sign!(signing_profile)

  signing_profile = {
       "extensions" => {
          "basicConstraints" => {"ca" => false},
          "certificatePolicies" => {
          "user_notice" => {
            "explicit_text" => certificate.text+'2',
            "organization" => certificate.organization
          }
        }
       }
    }

      plain_cert = CertificateAuthority::Certificate.new
      plain_cert.subject.common_name= certificate.domain
      plain_cert.serial_number.number=4
      plain_cert.key_material.generate_key
      plain_cert.parent = r # or intermediate
      plain_cert.sign!(signing_profile)

      return plain_cert.to_pem
end

def certificate_params
  params.require(:certificate).permit(:cert,  :domain,  :root,  :parent, :organization, :text)
end

end
