# generator-endo

[![Dependency status](http://img.shields.io/david/octoblu/generator-endo.svg?style=flat)](https://david-dm.org/octoblu/generator-endo)
[![devDependency Status](http://img.shields.io/david/dev/octoblu/generator-endo.svg?style=flat)](https://david-dm.org/octoblu/generator-endo#info=devDependencies)
[![Build Status](http://img.shields.io/travis/octoblu/generator-endo.svg?style=flat&branch=master)](https://travis-ci.org/octoblu/generator-endo)

A generator for [Yeoman](http://yeoman.io).

## Creating a Channel

### Install yo and the generator

```shell
npm install -g yo generator-endo
```

### Create a new project and run the generator

Note that the project directory name must start with `endo-`

```shell
mkdir endo-github
cd endo-github
yo endo
```

### Modify the passport configuration

The passport configuration is available in `src/api-strategy`. It's purpose is to map the API oauth profile to some required endo values in the `onAuthorization` function.

The callback passed in to the `onAuthorization` function expects a user object as its second parameter. The user object will be encrypted using the service's private key and stored on a credentials device that only the API service will have access to.

The properties listed are all required. However, the developer can add whatever additional properties they'd like. Keep in mind that every attribute that is not under the `secrets` key may be made available users authenticated by the API. In other words, if a user uses Oauth to authenicate the endo service as Twitter user @sqrtofsaturn, they may get access to all of the properties in the user object that are not under the `secrets` key.


##### User Required Properties

* `id`  The unique identifier that the API uses to identify this user. Is often an integer value.
* `username`  The visual identifier that the user would recognize as their username. It is used as the name of the device created for the user.
* `secrets`  Nothing under this key should ever be made available to anyone other than the Endo service itself.
  * `credentials` The credentials needed to make API requests.
    * `secret` The token used to make API requests.
    * `refreshToken` The token used to generate a new `secret` when it expires.

##### Example

```coffee
onAuthorization: (accessToken, refreshToken, profile, callback) =>
  callback null, {
    id: profile.id
    username: profile.username
    secrets:
      credentials:
        secret: accessToken
        refreshToken: refreshToken
  }
```

### Create a job

Jobs are stored in src/jobs. When the service first comes online, it will crawl through the src/jobs directory and generate a directory for each job that it finds. This generator will create one demo job for you. However, unless you're creating a Github Endo, the example will not be very useful.

#### Job directory format

```
src/
├── jobs
│   ├── list-events-by-user
│   │   ├── action.coffee
│   │   ├── index.coffee
│   │   ├── job.coffee
│   │   ├── form.cson
│   │   ├── message.cson
│   │   └── response.cson
```

##### list-events-by-user (Job directory)

The directory name will titleized be used as the job type identifier. For example, `list-events-by-user` will become the job type `ListEventsByUser`. The job will be executed by the message handler for incoming messages with a `metadata.jobType` that matches the job type identifier generated.

##### action.coffee

`action.coffee` exports a function that will be called for matching messages with the device options and the message, along with a callback that must be called to respond to the requester. The purpose of `action.coffee` is to map the function call API of the message handler to the Object Oriented API of the job. This file does not generally need to be modified.

##### index.coffee

`index.coffee` exports the functions and schema that make up the job in a standard structure. This file does not generally need to be modified.

##### job.coffee

`job.coffee` defines the job.

##### form.cson

`from.cson` defines how the form will be displayed to the user. Multiple form schemas can be defined for different message schema editors. It is recommended to nest the form schema under a key to target a specific form schema editor to make it easier to add support for additional editors in the future. The Octoblu Designer uses [Angular Schema Form](http://schemaform.io/) and the message handler expects the form schema to be nested under the `angular` key.

##### message.cson

`message.cson` defines the format all incoming messages must have in order to be processed by the job. Currently, messages that do not match the schema will still be allowed through to the Job, but that will likely change in the near future. A few additional properties will automatically be merged in to the message schema by the message handler before it's made available outside the Endo Service.

* `x-form-schema.angular`
* `x-response-schema`
* `properties.metadata.jobTypes`

##### response.cson
