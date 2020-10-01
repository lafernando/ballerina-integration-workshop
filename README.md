# Ballerina: Integration Workshop

[Ballerina](http://ballerina.io) is a programming language for the cloud-era; specializing in creating network connected applications. It brings together the higher level abstractions of middleware technologies, along with the flexibility of a general-purpose programming language. 

In this workshop, we will take a look at how the Ballerina platform can be used effectively in implementing integration scenarios. 

## Prerequisites

### Ballerina
Download and install Ballerina Swan Lake preview release [distribution](https://ballerina.io/downloads/) suitable for your operating system. 

Run the following to test the installation:

```bash
$ ballerina version
Ballerina Swan Lake Preview 4
Language specification v2020-09-22
Update Tool 0.8.8
```

### Visual Studio Code
Visual Studio Code is recommended as the editor for Ballerina projects. Install VS Code, and instal the Ballerina plugin available at Ballerina Swan Lake preview release [downloads](https://ballerina.io/downloads/). 

## Agenda
- Ballerina services and clients
  - Type system intro
  - Taint analysis intro
  - Writing an integration scenario for calling external services using the HTTP client and accepting JSON data
  - Working with JSON data
  - Service data binding, usage of open records
  - Query expressions for filtering and aggregating results
  - Error handling when communicating with external services
  - Intro to gRPC
- Data connector usage and streams
  - SQL connector
- Message queue technologies
  - RabbitMQ
- Scheduled tasks
- Transactions
- Security framework basics
  - BasicAuth, JWT
- Observability
  - Metrics
  - Distributed tracing
- [How to write connectors](https://docs.google.com/presentation/d/1QKJkzICwe4D66-5yuvv7h17r4eN8vmevAUKiuUNTX40/edit#slide=id.g37162d4181_0_273)
- [Ballerina coding best practices](https://docs.google.com/document/d/1H9-2TrZkfOa_wGOryL86PqCxUOVsk1AmwngeFldDbgg/edit?pli=1)

### Workshop Duration and Audience
The workshop is designed to be finished in 4 hrs. The general audience consists of developers and architects. Prior basic knowledge of a programming language is required. 

---

#### Quick Reference
 - [Ballerina by Example](https://ballerina.io/swan-lake/learn/by-example/)
 - [API Documentation](https://ballerina.io/swan-lake/learn/api-docs/ballerina/)
---