# micropost-formation

## Core components

* AWS VPC
* AWS ECS with ALB and AutoScaling
* AWS RDS
* Cloudflare DNS and CDN

## Dependencies

* Terraform
* AWS CLI
* direnv

## Getting started

Configure settings.

```
$ cp .envrc.example .envrc
$ vi .envrc
$ direnv allow
```

Init
```
$ export ENV=stg
$ source ./scripts/switch-role.sh
$ terraform init
$ terraform get
$ terraform workspace select ${ENV}
```

Plan and Apply

```
$ ./terraform-env.sh stg plan
$ ./terraform-env.sh stg apply
```

## Related Projects

* [Angular 2 app](https://github.com/springboot-angular2-tutorial/angular2-app)
* [Spring Boot app](https://github.com/springboot-angular2-tutorial/boot-app)
* [Android app](https://github.com/springboot-angular2-tutorial/android-app)
* [Lambda functions by Serverless](https://github.com/springboot-angular2-tutorial/micropost-functions)
