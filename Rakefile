task :default do
  url = 'https://packages.chef.io/files/stable/chefdk/4.0.60/ubuntu/18.04/chefdk_4.0.60-1_amd64.deb'
  sha256_checksum = '4ca4eb63b5a71e90bba7e91539bc5ecbad596a8e9daaadb0d53bb2219af961c4'
  output = 'chefdk.deb'

  sh <<~BASH
    if openssl dgst -sha256 chefdk.deb | grep #{sha256_checksum}; then
      exit 0
    fi

    rm -f #{output}
    wget -O #{output} #{url}

    berks install
    berks vendor
  BASH
end
