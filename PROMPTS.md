# Project Prompts

This file documents the prompts used during the development of this project.

## Initial Setup

### Prompt 1: Project Introduction

```
Project Ballastlane

Hey Claude. I've started this new project to demonstrate my skills as a software engineer.
I'll provide requirements during the development process with initial ideas
from my experience in order to get feedback and work together.

I've created an initial dockerized backend api, please take a look at this project to get familiar.
```

### Prompt 2: Initial Commit

```
Please, lets create the first commit using conventional commit message as dictated by https://www.conventionalcommits.org/en/v1.0.0/. I'll review your commit message.
```

## Authentication

### Prompt 3: JWT Authentication Implementation

```
Alright now let's implement a simple auth mechanism with jwt for the rails api. Lets avoid to use the devise gem for this solution, the jwt gem should be enough.

The requirements are:

For the auth API:

- Lets create a versioned AuthController considering the path '/api/v1' with endpoints for signup, login, logout, and refresh_token (in order to have better user experience).

- For the refresh token strategy lets consider the following: Refresh token expiration in 1 week (long live token) and access token expiration of 15 minutes expiration. For security purpose let's generate a new Access Token and a new Refresh Token when a request for refresh has been made.

In that sense, let's create a versioned auth controller for the features above considering the path '/api/v1/'.

For the auth data model:

- Lets create a simple active record User model with `username` and `password` fields. username should be only alpha numeric so lets provide validations for it. Lets provide automatic left/right trimming for the field. For the password lets validate the password with a length range of 5 to 64 characters, and also allow only alphanumeric and optionally (if they exists) the special characters . - ! \* #

- Lets consider to use a JTI revocation strategy in the same user model because we need a simple approach and we don't want multi-device access.

- Please add a seed file for an initial user creation with credentials: user: admin, password: admin.

- Lets create a README.file (in the root folder ) providing a section about the authentication process in the backend describing the endpoints available and curl commands to interact with them.

Let me know any further clarification you may need for execute this plan.
```
