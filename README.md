Description
===========

Sets up and manages users in a variety of different contexts.  Based around the original Opscode data-driven user creation by Joshua Timberman and Seth Chisamore.


Requirements
============

## Platforms

Tested on:

* Solaris 10
* Ubuntu 10.04

Data bag named `users` must exist.

## Cookbooks

If running on Solaris 10, the system needs to have been bootstrapped to use the publically provided EveryCity IPS/pkg(5) repository at http://s10.pkg.ec.  In the Atalanta Systems environment this is still done manually, and no cookbook or bootstrap mechanism exists for this.

To use the `users` cookbook in a Solaris 10 environment as described, you must have the `solaris` cookbook at the head of your run list.

Attributes
==========

sysadmins
---------

* `node['users']['home_base']` - base directory where user home directories live.  Default is `/home`

sharing
-------

* `node['users']['sharing_user']` - the userame which will be used for sharing.  Default is `atalanta`
* `node['users']['sharing_comment']` - the user comment for the sharing user.  Default is `Atalanta Systems Engineering`
* `node['users']['sharing_shell']` - the login shell for the sharing user.  Default is `/bin/bash`
* `node['users']['sharing_tools']` - an array of packages to install for collaborative purposes.  Take care, as only primitive checking is done to ensure the package name is correct for the platform.

Recipes
=======

default
-------

A placeholder - doesn't do anything.

sharing
-------

Sets up a user for collaborative co-working, with an authorized_keys file containing the keys for all users who wish to collaborate.  Also installs some useful tools.

sysadmins
---------

Creates a sysadmin group and users according to the `users` databag.  Drops off ssh public keys for each user in the sysadmin group.  Drops of a GNU screen config file with useful defaults, together with a shell profile to improve user experience on Solaris.

Usage
=====

The `users::sysadmins` recipe relies upon a databag called `users`.  Each data bag item corresponds to a user.  The databag can be extended to be used for arbitrary user such as user-specific preferences, or any other data which may logically be connected to a user.  An example databag is here:

    {
      "id": "konstantin",
      "ssh_keys": "ssh-rsa AAAAB3Nz...yhCw== konstantin",
      "groups": "sysadmin",
      "shell": "\/bin\/bash",
      "comment": "Konstantin Lysenko"
    }

Create the data bag:

    knife data bag create users
    
Create the data bag entry:

    cd $CHEF_REPO/databags/users
    cat <<EOF > user.json
    {
        "id": "user"
        ....
    }
    EOF

Upload the data bag:

    knife data bag from file user.json

Ensure the user's public ssh key is entered into the ssh_keys value.  The `users::sysadmins` recipe will create a `sysadmin` group with the id of 2300.  If the user is set to be in this group, their key will be dropped off, and key-based ssh will be possible.  Ensure that the path to the shell you specify in the data bag exists.

Changes/Roadmap
===============

## Future

* Make sharing authorized_keys dynamic rather than static, probably iterating over a databag with an element indicating if the user should be a sharer.

## 1.0.0:

* Initial release

License and Author
==================

Author:: Atalanta Systems (<support@atalanta-systems.com>)

Copyright:: 2011, Atalanta Systems Ltd