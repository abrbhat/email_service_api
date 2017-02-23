# Problem
Create a service that accepts the necessary information and sends emails. It should provide an abstraction between two different email service providers. If one of the services goes down, your service can quickly failover to a different provider without affecting your customers.

# Solution
A RESTful API built with Ruby on Rails and Postgres. The API interacts with various
providers through a failover mechanism.

The solution focuses on the *Back-end Track*.

# Technical Stack Deployed

## Ruby on Rails 5 (API mode)
* Extremely solid framework for building production-ready apps in a short amount of time
* Routing DSL is well-suited for RESTful interactions
* Has a wide variety of gems to handle various functionalities while keeping things DRY
* Rails 5 provides API mode which loads only selective middleware, keeping the response times
as short as possible

## Postgres
* Most advanced relational database
* Battle-hardened in production-level deployments

# API Documentation
The appl

## Endpoints

### /api/v1/emails

### POST /api/v1/emails

#### Query Parameters

| Parameter          | Type                | Required     |
| ------------------ | --------------------|--------------|
| api_key            | Text                | yes          |
| email[subject]     | Text                | yes          |
| email[body]        | Text                | yes          |
| email[to]          | Array of email_ids  | no           |
| email[cc]          | Array of email_ids  | no           |
| email[bcc]         | Array of email_ids  | no           |
| email[attachments] | Array of files      | no           |

Note: Parameters to, cc and bcc are individually optional but at least one email
id should be present in at least one of the parameters

#### Responses

##### HTTP Status: 200
Email has been processed successfully. Response contains delivery status for individual
recipients.

###### Example

Query:

```
curl -X POST \
     -H "Content-Type: multipart/form-data;" \
     -F "email[subject]=Hi There" \
     -F "email[to][]=bhatnagarabhiroop@gmail.com" \
     -F "email[body]=Just messaging to say hi" \
     -F "api_key=api_key_1" \
     "http://localhost:3000/api/v1/emails"
```

Response:

```
{
  "status": [
    {
      "email_id": "test@example.com",
      "type": "to",
      "status": "sent",
      "error": null
    }
  ]
}
```

##### HTTP Status: 401
Incorrect or invalid API key provided

###### Example

Query:

```
curl -X POST \
     -H "Content-Type: multipart/form-data;" \
     -F "email[subject]=Hi There" \
     -F "email[to][]=bhatnagarabhiroop@gmail.com" \
     -F "email[body]=Just messaging to say hi" \
     -F "api_key=any_random_string" \
     "http://localhost:3000/api/v1/emails"
```

Response:

```
{
  "errors": [
    "invalid_api_key"
  ]
}
```

##### HTTP Status: 422
Error in query

###### Example

Query:

```
curl -X POST \
     -H "Content-Type: multipart/form-data;" \
     -F "email[subject]=Hi There" \
     -F "email[body]=Just messaging to say hi" \
     -F "api_key=api_key_1" \
     "http://localhost:3000/api/v1/emails"
```

Response:

```
{
  "errors": [
    "no_recipient_present"
  ]
}
```

##### HTTP Status: 503
Email could not be sent with any of the providers

###### Example

Query:

```
curl -X POST \
     -H "Content-Type: multipart/form-data;" \
     -F "email[subject]=Hi There" \
     -F "email[body]=Just messaging to say hi" \
     -F "email[to][]=bhatnagarabhiroop@gmail.com" \
     -F "api_key=api_key_1" \
     "http://localhost:3000/api/v1/emails"
```

Response:

```
{
  "errors": [
    "service_unavailable"
  ]
}
```

# Run
```
bundle install
rails server
```
# Test
```
rspec spec/
```
# Technical Trade-offs
Since I had very limited amount of time to develop a production-ready system, I went ahead with RoR and Postgres. But if I had more time, I would have chosen Node, Express and Redis.
* Node's non-blocking functionality will fit really well with the
requirements since the API will involve extensive file-uploading and external API invocations.
* Express is very light-weight and since there is only a single endpoint, there is no need
of the extensive routing that Rails provides.
* The system requires a database just to check if the API key belongs to a valid account. This functionality can be easily achieved by an in-memory database like Redis. Using Redis would cut down further on the response time.

# Link to other code
http://github.com/abrbhat/customer-support

# Link to profile
http://github.com/abrbhat
https://www.linkedin.com/in/abhiroopbhatnagar/

# Hosted at Heroku
https://email-service-api-73686.herokuapp.com/
