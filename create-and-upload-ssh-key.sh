github_user="danwizard208"
api_root="https://api.github.com"

# Generate a key pair for this machine
echo "Runnish ssh-keygen to generate a key pair for this machine."
echo "This script assumes a public key will exist at ~/id_rsa.pub (ssh-keygen default)."
ssh-keygen

# Request OAuth token to add the public key - will prompt for password
jq --arg host `hostname` '.note += $host' auth_token.json | \
    curl -H "Content-Type: application/json;" -X POST -u "$github_user" "$api_root/authorizations" --data '@-' \
    > token.json;
token=$(jq -r '.token' token.json)
id=$(jq -r '.id' token.json)
rm token.json

# Add the public key to github
add_key_json=$(jq --arg title `hostname` --arg key "$(cat ~/.ssh/id_rsa.pub)" -n '{title:$title, key:$key}')
curl -H "Content-Type: application/json;" -H "Authorization: token $token" -X POST "$api_root/user/keys" --data "$add_key_json"

# Delete OAuth token now that we're done with it - will prompt for password
curl -X DELETE -u $github_user "$api_root/authorizations/$id"
