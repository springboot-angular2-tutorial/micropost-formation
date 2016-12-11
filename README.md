# micropost-formation

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

Plan and Apply

```
$ ./terraform-env.sh stg get
$ ./terraform-env.sh stg plan
$ ./terraform-env.sh stg apply
```

## Related Projects

* [Angular2 app](https://github.com/springboot-angular2-tutorial/angular2-app)
* [Spring Boot app](https://github.com/springboot-angular2-tutorial/boot-app)
* [Android app](https://github.com/springboot-angular2-tutorial/android-app)
* [Server provisioning by Ansible and Packer](https://github.com/springboot-angular2-tutorial/micropost-provisionings)
* [Lambda functions by Serverless](https://github.com/springboot-angular2-tutorial/micropost-functions)
