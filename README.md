# ssm - simple secrets management
[![License: LGPL v3](https://img.shields.io/badge/License-LGPL%20v3-blue.svg)](https://www.gnu.org/licenses/lgpl-3.0)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Motivation](#motivation)
- [Installation](#installation)
- [Usage](#usage)
- [Security suggestions](#security-suggestions)
- [Useful tools to use ssm with](#useful-tools-to-use-ssm-with)
- [FAQ](#faq)
- [License](#license)
- [Roadmap](#roadmap)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

A simple tool to easily and securely share secrets within a team, using [GPG](https://en.wikipedia.org/wiki/GNU_Privacy_Guard) and Git. No extra tools, servers or SaaS systems needed.


## Motivation
As a freelancer, I came across many teams where secrets management was done a bit ad-hoc. Most teams were using .env files. Often you would have a .env.sample file to start with, and then you needed to get the secrets from another team member. Some were using etcd. Some were using pass. Some teams were using full-featured solutions like Hashicorp Consul, Vault, or similar.

While these are all fine choices, it seemed that either:

- The overhead added from "proper" secrets management was more than necessary for a small team.
- The adding or removing of secrets was done in a too ad-hoc way, causing confusion and weird local bugs. 
- Onboarding new developers was made more difficult by not having a structured way of shering secrets.

I was missing an extremely simple tool that required no new infrastructure or tools, while allowing to conveniently and securely share secrets in a small company or team.

## Installation
### Via install script
##### Change to your project directory
```
cd my_project_folder
```
##### Run [install script](https://raw.githubusercontent.com/houen/ssm/install-script/install.sh)
```
bash <(curl -s https://raw.githubusercontent.com/houen/ssm/master/install.sh)
```
<!-- 

bash <(curl -s https://raw.githubusercontent.com/houen/ssm/install-script/install.sh)

-->

### Manual installation
Note that the installation here only needs to be done once per project. New employees checking out the repository only need to add their GPG keys.

##### cd to your project folder
```
cd my_project_folder
```

##### Clone this repository into your project as ssm, and remove ssm/.git folder
```
git clone --depth 1 -q -- git@github.com:houen/ssm.git ssm && rm -Rf ssm/.git
```

##### Add your GPG key
`KEY_ID` can be either the Key email, Key name, Key ID, or Key fingerprint. I recommend using the key email for consistent naming within the team.

```
# Repeat for every team member GPG key
ssm/bin/import_pubkey KEY_ID
```

This will store the pubkey file `ssm/config/pubkeys/KEY_ID.pub`, and add KEY_ID as an entry in `ssm/config/gpg_keys`

##### Add the files you wish to have encrypted
The files will be added to the list at `ssm/config/secret_files`
```
# Examples:
ssm/bin/add_secret_file .env
ssm/bin/add_secret_file some_dir/secret
```

##### Add a line to your .gitignore to not ignore .ssm.gpg files
```
echo '!*.ssm.gpg' >> .gitignore
```

##### Encrypt secrets
```
# Will create a file.ssm.gpg file for each file listed in ssm/config/secret_files
# The files will be decryptable by all GPG keys listed in ssm/config/gpg_keys

ssm/bin/encrypt_secrets
```

Done! 

Your secrets are now encrypted and stored with the ending .ssm.gpg. You can now commit the encrypted secrets to version control and push to your git repository. 

Encrypted secrets can be decrypted with `ssm/bin/decrypt_secrets` by any member of your team whose GPG keys were added above.

## Usage
### Encrypting secret files
```
# (Developer has added a DB_PASSWORD to the .env file)
ssm/bin/encrypt_secrets
git commit -am "adding DB_PASSWORD to .env"
git push
```

This will allow all developers to pull the branch with the updated secrets, run ssm/bin/decrypt_secrets, and have all of the newly added/updated secrets.

### Decrypting secret files
```
git pull
ssm/bin/decrypt_secrets
```
Now the secrets files will be added / overridden with the new values.

### Adding a new secret file
- `cd` to your project folder
- run `ssm/bin/add_secret_file FILE_NAME`
- Then, from your project folder run `ssm/bin/encrypt_secrets` and push to git.

### Adding a new developer who should be able to read the secret files
- First, the user needs to generate a GPG key. See [GitHub's guide to doing so here](https://help.github.com/articles/generating-a-new-gpg-key/).
- After the key is generated, have them run `bin/import_pubkey KEY_ID` to add their key to the ssm/pubkeys dir and ssm/gpg_keys
- Have them commit and push to git
- Now, someone with access can pull the relevant git branch, e.g. DEV-42-onboard-soren, decrypt the secrets, run `ssm/bin/encrypt_secrets`, then push to git.
- Now the new developer can pull the branch, run ssm/bin/decrypt_secrets, and they will have all the shared secrets.

### Removing a developer
To remove a developer:

- Remove their key ID from ssm/gpg_keys
- Remove their public key from ssm/pubkeys. Secrets will no longer be encrypted with their GPG public key.
- Run `ssm/bin/encrypt_secrets`
- Commit and push

The removed gpg key will now no longer be able to decrypt secrets.

## Security suggestions
### Layered security / Defense-in-depth
It is a good idea to protect your important / dangerous secrets behind [multiple layers of security](https://en.wikipedia.org/wiki/Defense_in_depth_(computing)).

Any encryption protocol can have weaknesses. I would not use ssm to encrypt dangerous secrets in an open-source project where everyone can get to them. It is *probably* safe. Then again it might not be. If anyone can point me to an article explaining sufficiently why it is perfectly safe, I would very much appreciate it.

However I feel perfectly comfortable using ssm to encrypt moderately-important secrets within private Git repositories on GitHub, or even better, a self-hosted Git repository. I personally use the following:

- Private GitHub repository
- 2FA on my Github account
- ssm

In order for someone to steal the (not actually that valuable) secrets in my repositories, they would have to break either my password plus 2FA, or into Github itself, and *then* start cracking my strong GPG encryption. If someone is that motivated there are easier ways I'm sure.

### Strong key passphrases
Make sure your team use good strong passphrases on their secret keys. This makes it hard to crack the secrets even if someone were to get a hold of the key itself. However, since the secret files will in most cases probably be lying around the hard drive of your developers, there are easier attack vectors than cracking the GPG keys for a determined attacker. 

PS: We developers should always be using encrypted hard drives.

## Useful tools to use ssm with
### General
- [direnv](https://github.com/direnv/direnv) which autoloads a .env file when entering a directory from shell. 
    - This for example works well with Terraform for managing secrets stored as TF_VAR_xyz env vars

### Ruby
- [dotenv](https://github.com/bkeepers/dotenv) gem for Ruby / Rails

### Python
- [python-dotenv](https://github.com/theskumar/python-dotenv) library

## FAQ
- Can I encrypt certain files for only certain people / keys, for example .env.production?
  - This would be very useful indeed. However, I want to see if this proiject is useful for other people than myself before working on it. Please open a pull request if you have the time to implement this.

## License
Please see [LICENSE](https://github.com/houen/ssm/blob/master/LICENSE) for license details.

<!-- ## Contributing
### Install specific branch
```
git clone --single-branch --branch BRANCH_NAME --depth 1 -q -- git@github.com:houen/ssm.git ssm
``` -->

## Roadmap
- Upgrade instructions
  <!-- - move ssm dir to ssm_upgrade_tmp dir
  - download new version
  - move files back to newly downloaded version
  ```
  mv ssm_upgrade_tmp/pubkeys/*.pub ssm/pubkeys/.
  mv ssm_upgrade_tmp/secret_files ssm/secret_files
  mv ssm_upgrade_tmp/gpg_keys ssm/gpg_keys
  ``` -->
- Add README note on always changing / updating secrets in separate branches to minimize conflict risk.
- Add README section on offboarding developers / reencrypting / why secrets can never truly be "revoked".
- bin/update_ssm script for pulling new ssm versions
- bin/check_if_secrets_up_to_date script for letting users know when they should run bin/decrypt_secrets
