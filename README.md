# ssm - simple secrets management
[![License: LGPL v3](https://img.shields.io/badge/License-LGPL%20v3-blue.svg)](https://www.gnu.org/licenses/lgpl-3.0)

A simple tool to easily and securely share secrets within a team, using [GPG](https://en.wikipedia.org/wiki/GNU_Privacy_Guard) and Git. No extra tools, servers or SaaS systems needed.


## Motivation
As a freelancer, I came across many teams where secrets management was done a bit ad-hoc. Most teams were using .env files. Often you would have a .env.sample file to start with, and then you needed to get the secrets from another team member. Some were using etcd. Some were using pass. Some teams were even using full-featured solutions like Hashicorp Consul, Vault, or similar.

While these are all fine choices, I was missing an extremely simple tool that required no new infrastructure while allowing to conveniently and securely share secrets in a small company or team.

## Usage
### Installation
Note that the installation here only needs to be done once per project. New employees checking out the repository only need to add their GPG keys.

#### cd to your project folder
```
cd my_project_folder
```

#### Clone this repository into your project as .ssm, and remove git folder
```
git clone --depth 1 -q -- git@github.com:houen/ssm.git .ssm && rm -Rf .ssm/git
```

#### Add your GPG key
```
# Repeat for every team member GPG key
.ssm/bin/import_pubkey KEY_ID
```
`KEY_ID` can be either the Key name, Key ID, or Key fingerprint

#### Add the files you wish to have encrypted to .ssm/secret_files
```
# Example:
.ssm/bin/add_secret_file .env
.ssm/bin/add_secret_file some_dir/secret
```

#### Add a line to your .gitignore to not ignore .ssm.gpg files
```
echo "!*.ssm.gpg" > .gitignore
```

#### Encrypt secrets
```
# Will create a file.ssm.gpg file for each file listed in .ssm/secret_files
.ssm/bin/encrypt_secrets
```

Done. You can now encrypt secrets with `.ssm/bin/encrypt_secrets`, and commit them to version control. Encrypted secrets can be decrypted with `.ssm/bin/decrypt_secrets` by any member of your team.

### Daily usage
#### Encrypting secret files
```
.ssm/bin/encrypt_secrets
git commit -am "adding DB_PASSWORD to .env"
git push
```

This will allow all developers to pull the branch with the updated secrets, run .ssm/bin/decrypt_secrets, and have all of the newly added/updated secrets.

#### Decrypting secret files
```
git pull
.ssm/bin/decrypt_secrets
```
Now the secrets files will be added / overridden with the new values.

#### Adding a new secret file
- `cd` to your project folder
- run `.ssm/bin/add_secret_file FILE_NAME`
- Then, from your project folder run `.ssm/bin/encrypt_secrets` and push to git.

#### Adding a new developer who should be able to read the secret files
- First, the user needs to generate a GPG key. See [GitHub's guide to doing so here](https://help.github.com/articles/generating-a-new-gpg-key/).
- After the key is generated, have them run `bin/import_pubkey KEY_ID` to add their key to the .ssm/pubkeys dir and .ssm/gpg_keys
- Have them commit and push to git
- Now, someone with access can pull the relevant git branch, e.g. DEV-42-onboard-soren, decrypt the secrets, run `.ssm/bin/encrypt_secrets`, then push to git.
- Now the new developer can pull the branch, run .ssm/bin/decrypt_secrets, and they will have all the shared secrets.

## FAQ
- Can I encrypt certain files for only certain people / keys, for example .env.production?
  - This would be very useful indeed. However, I want to see if this proiject is useful for other people than myself before working on it. Please open a pull request if you have the time to implement this.

## License
Please see [LICENSE](https://github.com/houen/ssm/blob/master/LICENSE) for license details.