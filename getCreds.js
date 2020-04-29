const args = process.argv.slice(2);
const credential = args[0];

function getCredential(credential) {
  const vcap_services = JSON.parse(process.env.VCAP_SERVICES);
  const mysql = vcap_services["p.mysql"];
  const value = mysql["credentials"][credential];
  return value;
}

console.log(getCredential(credential));
