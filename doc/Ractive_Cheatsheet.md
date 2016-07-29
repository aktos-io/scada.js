# Ractive Cheatsheet

1. What you can do
2. How you can do


# 1. You can listen for component events on main instance

```
# login component's ls

if is-login-success! then fire \success

# html
login()

+if('login.ok')
    p Hello!

# ls
ractive.on do
    'login.success': ->
        ractive.set \login.ok, yes
```
