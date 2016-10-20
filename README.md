# micropost-formation

## Dependencies

* Terraform
* Node.js
* AWS CLI
* direnv

## Getting started

Configure settings.

```
$ cp .envrc.example .envrc
$ vi .envrc
$ direnv allow
```

Install gems.

```
$ bundle install
```

Plan and Apply

```
$ ./terraform-env.sh stg get
$ ./terraform-env.sh stg plan
$ ./terraform-env.sh stg apply
```
