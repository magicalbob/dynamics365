dyn_ip=$(terraform show --json|jq .values.root_module.resources|jq ".[]|select(.name|test(\"$1\"))"|jq .values.public_ip|cut -d\" -f2)
if [[ "" == "${dyn_ip}" ]]
then
  echo "No such machine"
  exit 1
fi
xfreerdp --no-tls -u vagrant -p V8gr^nt123456789 ${dyn_ip}
