# Open OnDemand reporting utilities.

Open OnDemand reporting utilities.  Use these scripts to report on usage
of the Open OnDemand platform at your site.

We've provided shell and ruby scripts to do this. You may choose to execute
either varaint as they both do the same thing.  Some users may just be more
familiar or comfortable running a bash script instead of a Ruby script.

## Executing

To run these scripts, simply clone this repository and run the commands
on the Open OnDemand's webserver node.

## Reporting on the number of users.

`count_ood_users` (`.rb` and `.sh`) searches your `httpd` (or `apache2`)
log files to find all the users that have logged into the system and reports on them.

Both shell and ruby variants do the same thing.

```
[ood-reporting-utils(main)]  ./count_ood_users.sh 
5 users have logged into this system since 09-27-2023.
```

And the ruby variant:
```
[ood-reporting-utils(main)]  ./count_ood_users.rb
5 users have logged into this system since 09-27-2023
```

## Reporting on the apps a user has access to.

`count_ood_apps` (`.rb` and `.sh`) report on the OnDemand applications
your current user has access to.

```
[ood-reporting-utils(main)]  ./count_ood_apps.sh
The user johrstrom has access to:
  27 system installed applications.
  10 shared applications.

system installed apps are:

activejobs
# ... list removed for brevity
```

And the ruby variant:
```
[ood-reporting-utils(main)]  ./count_ood_apps.rb 
The user johrstrom has access to:
  27 system installed applications.
  10 shared applications.

system installed apps are:

bc_osc_pymol
# ... list removed for brevity
```

Note that the list order of the system installed apps may differ from bash to
ruby.
