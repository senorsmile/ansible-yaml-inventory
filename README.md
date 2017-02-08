# ansible-yaml-inventory
Example showing how to use the new yaml based inventory in Ansible.

## test all the things
```
ansible all -i inventory/ -m raw -a uptime
```
